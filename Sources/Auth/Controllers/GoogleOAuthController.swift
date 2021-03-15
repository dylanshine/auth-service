import Vapor
import Fluent
import JWT

struct GoogleOAuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("google") { auth in
            auth.get("login", use: login)
            auth.get("redirect", use: redirect)
        }
    }
    
    private func login(_ req: Request) throws -> EventLoopFuture<Response> {
        let platform: OAuth.Platform = (try? req.query.get(at: OAuth.platform)) ?? .web
        
        let state = try req.jwt.sign(OAuth.State(platform: platform))
        
        let authURL = try OAuth.Google.authURL(state: state)
        
        let response: Response = req.redirect(to: authURL)
        
        return req.eventLoop.makeSucceededFuture(response)
    }
    
    private func redirect(_ req: Request) throws -> EventLoopFuture<TokenResponse> {
        
        if let error: String = try req.query.get(at: OAuth.errorKey) {
            throw Abort(.badRequest, reason: error)
        }
        
        guard let code: String = try req.query.get(at: OAuth.codeKey) else {
            throw Abort(.badRequest, reason: "Missing 'code' key in URL query")
        }
        
//        guard let stateJWT: String = try req.query.get(at: OAuth.stateKey) else {
//            throw Abort(.badRequest, reason: "Missing 'state' key in URL query")
//        }
//        
//        let state: OAuth.State = try req.jwt.verify(stateJWT)
        
        let body = OAuth.Google.accessTokenRequestBody(code: code)
        let uri = OAuth.Google.accessTokenURI
        let headers = OAuth.Google.accessTokenHeaders
        
        return body.encodeResponse(for: req)
            .map { $0.body.buffer }
            .flatMap { buffer in
                return req.client.post(uri, headers: headers) { $0.body = buffer }
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
