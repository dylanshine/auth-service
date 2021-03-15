import Vapor
import Fluent

protocol OAuthController {
    associatedtype Provider: OAuthURLProvider
}

extension OAuthController {
    func login(_ req: Request) throws -> EventLoopFuture<Response> {
        let platform: OAuth.Platform = (try? req.query.get(at: OAuth.platformKey)) ?? .web
        
        return req.nonce.create().flatMapThrowing { nonce in
            let state = try req.jwt.sign(OAuth.State(platform: platform, nonce: nonce))
            
            let authURL = try Provider.authURL(state: state)
            
            return req.redirect(to: authURL)
        }
    }
}

