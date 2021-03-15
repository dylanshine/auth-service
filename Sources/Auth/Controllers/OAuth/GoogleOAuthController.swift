import Vapor
import Fluent
import JWT

struct GoogleOAuthController: RouteCollection, OAuthController {
    typealias Provider = OAuth.Google
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("google") { auth in
            auth.get("login", use: login)
            auth.get("redirect", use: redirect)
        }
    }
    
    private func redirect(_ req: Request) throws -> EventLoopFuture<TokenResponse> {
        
        if let error: String = try req.query.get(at: OAuth.errorKey) {
            throw Abort(.badRequest, reason: error)
        }
        
        guard let code: String = try req.query.get(at: OAuth.codeKey) else {
            throw Abort(.badRequest, reason: "Missing 'code' key in URL query")
        }
        
        guard let stateJWT: String = try req.query.get(at: OAuth.stateKey) else {
            throw Abort(.badRequest, reason: "Missing 'state' key in URL query")
        }
        
        let state: OAuth.State = try req.jwt.verify(stateJWT)
        
        return req.nonce.validate(nonce: state.nounce).flatMap {
            let body = OAuth.Google.accessTokenRequestBody(code: code)
            
            return body.encodeResponse(for: req)
                .map { $0.body.buffer }
                .flatMap { buffer in
                    return req.client.post(OAuth.Google.uri, headers: OAuth.Google.headers) { $0.body = buffer }
                }.flatMap { response -> EventLoopFuture<GoogleIdentityToken> in
                    // Currently not storing Access Token, may use in future...
                    do {
                        let tokenResponse = try response.content.decode(OAuth.Google.TokenResponse.self)
                        return req.jwt.google.verify(tokenResponse.idToken)
                    } catch {
                        return req.eventLoop.makeFailedFuture(error)
                    }
                }.flatMap { idToken in
                    
                    guard let email = idToken.email else {
                        return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Missing email in Google ID Token"))
                    }
                    
                    return req.oAuthUserHandler.handle(GoogleUser.self,
                                                       id: idToken.subject.value,
                                                       email: email,
                                                       firstName: idToken.givenName ?? "",
                                                       lastName: idToken.familyName ?? "").flatMap { user in
                                                        return req.tokenGenerator.response(for: user)
                                                       }
                }
        }
    }
}
