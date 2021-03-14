import Vapor
import Fluent
import XSJWT

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { auth in
            auth.post("register", use: register)
            auth.post("login", use: login)
            
            auth.group("email-verification") { emailVerificationRoutes in
                emailVerificationRoutes.post("", use: sendEmailVerification)
                emailVerificationRoutes.get("", use: verifyEmail)
            }
            
            auth.group("reset-password") { resetPasswordRoutes in
                resetPasswordRoutes.post("", use: resetPassword)
                resetPasswordRoutes.get("verify", use: verifyResetPasswordToken)
            }
            auth.post("recover", use: recoverAccount)
            
            auth.post("accessToken", use: refreshAccessToken)
            
            auth.group(XSJWT.Authenticator()) { authenticated in
                authenticated.get("me", use: getCurrentUser)
            }
        }
    }
    
    private func register(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try RegisterRequest.validate(content: req)
        let registerRequest = try req.content.decode(RegisterRequest.self)
        guard registerRequest.password == registerRequest.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }
        
        return req.password
            .async
            .hash(registerRequest.password)
            .map { User(from: registerRequest, passwordHash: $0) }
            .flatMap { user in
                user.create(on: req.db)
                    .flatMapErrorThrowing {
                        if let dbError = $0 as? DatabaseError, dbError.isConstraintFailure {
                            throw AuthenticationError.emailAlreadyExists
                        }
                        throw $0
                }
                .flatMap { req.emailVerifier.verify(for: user) }
        }
        .transform(to: .created)
    }
    
    private func login(_ req: Request) throws -> EventLoopFuture<LoginResponse> {
        try LoginRequest.validate(content: req)
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        return User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first()
            .unwrap(or: AuthenticationError.invalidEmailOrPassword)
            .guard({ $0.isEmailVerified }, else: AuthenticationError.emailIsNotVerified)
            .flatMap { user -> EventLoopFuture<User> in
                return req.password
                    .async
                    .verify(loginRequest.password, created: user.password)
                    .guard({ $0 == true }, else: AuthenticationError.invalidEmailOrPassword)
                    .transform(to: user)
            }
            .flatMap { user in
                
                do {
                    let token = [UInt8].generate(bits: 256)
                    
                    let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
                    
                    return refreshToken.create(on: req.db)
                        .flatMapThrowing {
                        
                            let payload = try Payload(user: user)
                            
                            return try LoginResponse(
                                user: User.DTO(user: user),
                                accessToken: req.jwt.sign(payload),
                                refreshToken: token)
                        }
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
        }
    }
    
    private func refreshAccessToken(_ req: Request) throws -> EventLoopFuture<AccessTokenResponse> {
        let accessTokenRequest = try req.content.decode(AccessTokenRequest.self)
        let hashedRefreshToken = SHA256.hash(accessTokenRequest.refreshToken)
        
        return RefreshToken.query(on: req.db)
            .filter(\.$token == hashedRefreshToken)
            .first()
            .unwrap(or: AuthenticationError.refreshTokenOrUserNotFound)
            .flatMap { $0.delete(on: req.db).transform(to: $0) }
            .guard({ $0.expiresAt > Date() }, else: AuthenticationError.refreshTokenHasExpired)
            .flatMap { User.find($0.$user.id, on: req.db) }
            .unwrap(or: AuthenticationError.refreshTokenOrUserNotFound)
            .flatMap { user in
                do {
                    let token = [UInt8].generate(bits: 256)
                    let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
                    
                    let payload = try Payload(user: user)
                    let accessToken = try req.jwt.sign(payload)
                    
                    return refreshToken.create(on: req.db)
                        .transform(to: (token, accessToken))
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
        }
        .map { AccessTokenResponse(refreshToken: $0, accessToken: $1) }
    }
    
    private func getCurrentUser(_ req: Request) throws -> EventLoopFuture<User.DTO> {
        let payload = try req.auth.require(Payload.self)
        
        return User.find(payload.id, on: req.db)
            .unwrap(or: AuthenticationError.userNotFound)
            .map { .init(user: $0) }
    }
    
    private func verifyEmail(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let token = try req.query.get(String.self, at: "token")
        
        let hashedToken = SHA256.hash(token)
        
        return EmailToken.query(on: req.db)
            .filter(\.$token == hashedToken)
            .first()
            .unwrap(or: AuthenticationError.emailTokenNotFound)
            .flatMap { $0.delete(on: req.db).transform(to: $0) }
            .guard({ $0.expiresAt > Date() }, else: AuthenticationError.emailTokenHasExpired)
            .flatMap {
                return User.query(on: req.db)
                    .filter(\.$id == $0.$user.id)
                    .set(\.$isEmailVerified, to: true)
                    .update()
        }
        .transform(to: .ok)
    }
    
    private func resetPassword(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let resetPasswordRequest = try req.content.decode(ResetPasswordRequest.self)
        
        return User.query(on: req.db)
            .filter(\.$email == resetPasswordRequest.email)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap {
                return req.passwordResetter
                    .reset(for: $0)
                    .transform(to: .accepted)
            }
    }
    
    private func verifyResetPasswordToken(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let token = try req.query.get(String.self, at: "token")
        let hashedToken = SHA256.hash(token)
        
        return PasswordToken.query(on: req.db)
            .filter(\.$token == hashedToken)
            .first()
            .unwrap(or: AuthenticationError.invalidPasswordToken)
            .flatMap { passwordToken in
                guard passwordToken.expiresAt > Date() else {
                    return passwordToken.delete(on: req.db)
                        .transform(to: req.eventLoop
                            .makeFailedFuture(AuthenticationError.passwordTokenHasExpired)
                    )
                }
                
                return req.eventLoop.makeSucceededFuture(.noContent)
        }
    }
    
    private func recoverAccount(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try RecoverAccountRequest.validate(content: req)
        let content = try req.content.decode(RecoverAccountRequest.self)
        
        guard content.password == content.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }
        
        let hashedToken = SHA256.hash(content.token)
        
        return PasswordToken.query(on: req.db)
            .filter(\.$token == hashedToken)
            .first()
            .unwrap(or: AuthenticationError.invalidPasswordToken)
            .flatMap { passwordToken -> EventLoopFuture<Void> in
                guard passwordToken.expiresAt > Date() else {
                    return passwordToken.delete(on: req.db)
                        .transform(to: req.eventLoop
                            .makeFailedFuture(AuthenticationError.passwordTokenHasExpired)
                    )
                }
                
                return req.password
                    .async
                    .hash(content.password)
                    .flatMap { digest in
                        return User.query(on: req.db)
                            .filter(\.$id == passwordToken.$user.id)
                            .set(\.$password, to: digest)
                            .update()
                    }
                    .flatMap {
                        PasswordToken.query(on: req.db)
                            .filter(\.$user.$id == passwordToken.$user.id)
                            .delete()
                    }
        }
        .transform(to: .noContent)
    }
    
    private func sendEmailVerification(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let content = try req.content.decode(SendEmailVerificationRequest.self)
        
        return User.query(on: req.db)
            .filter(\.$email == content.email)
            .first()
            .flatMap { user -> EventLoopFuture<HTTPStatus> in
                guard let user = user, !user.isEmailVerified else {
                    return req.eventLoop.makeSucceededFuture(.noContent)
                }
                
                do {
                    let id = try user.requireID()
                    
                    return EmailToken.query(on: req.db)
                        .filter(\.$user.$id == id)
                        .delete()
                        .flatMap { _ in
                            return req.emailVerifier
                                .verify(for: user)
                                .transform(to: .noContent)
                        }
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
            }
    }
}
