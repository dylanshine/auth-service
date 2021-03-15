import Vapor
import Fluent
import JWT

struct AppleOAuthController: RouteCollection, OAuthController {
    typealias Provider = OAuth.Apple
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("apple") { auth in
            auth.get("login", use: login)
            auth.post("redirect", use: redirect)
        }
    }
    
    private func redirect(_ req: Request) throws -> EventLoopFuture<TokenResponse> {

        let response = try req.content.decode(OAuth.Apple.AuthResponseBody.self)
        let state: OAuth.State = try req.jwt.verify(response.state)
        
        return req.nonce.validate(nonce: state.nounce).flatMap {
            return req.jwt.apple.verify(response.idToken, applicationIdentifier: OAuth.Apple.clientID).flatMap { token in
            
                do {
                    let clientSecret = try req.jwt.sign(OAuth.Apple.authToken, kid: OAuth.Apple.kid)
                    let body = try OAuth.Apple.authTokenRequestBody(code: response.code, clientSecret: clientSecret, grantType: .auth)
                    
                    return body.encodeResponse(for: req)
                        .map { $0.body.buffer }
                        .flatMap { buffer in
                            return req.client.post(OAuth.Apple.uri, headers: OAuth.Apple.headers) { $0.body = buffer }
                        }
                        .flatMap { response -> EventLoopFuture<AppleIdentityToken> in
                            do {
                                // Not using Access or Refresh Token, may utilze in future
                                let tokenResponse = try response.content.decode(OAuth.Apple.TokenResponse.self)
                                return req.jwt.apple.verify(tokenResponse.idToken)
                            } catch {
                                return req.eventLoop.makeFailedFuture(error)
                            }
                            
                        }.flatMap { idToken in
                            
                            guard let email = idToken.email else {
                                return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Missing email in Apple ID Token"))
                            }
                            
                            return req.oAuthUserHandler.handle(AppleUser.self,
                                                               id: idToken.subject.value,
                                                               email: email,
                                                               firstName: response.user?.name.firstName ?? "",
                                                               lastName: response.user?.name.lastName ?? "").flatMap { user in
                                                                return req.tokenGenerator.response(for: user)
                                                               }
                        }
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
            }
        }
    }
}
