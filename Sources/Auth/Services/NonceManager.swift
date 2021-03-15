import Vapor
import Fluent
import CryptoKit

struct NonceManager {
    let database: Database
    let eventLoop: EventLoop
    
    func create() -> EventLoopFuture<String> {
        let encodedNonceString = Data(ChaChaPoly.Nonce()).base64EncodedString()
        let nonce = Nonce(nonce: encodedNonceString,
                          expiresAt: .nonceRequestLifetime)
        
        return nonce.create(on: database).transform(to: encodedNonceString)
    }
    
    func validate(nonce: String) -> EventLoopFuture<Void> {
        return Nonce.query(on: database)
            .filter(\.$nonce == nonce)
            .first()
            .unwrap(or: Abort(.notFound))
            .guard({ $0.expiresAt > Date() }, else: AuthenticationError.nonceExpired)
            .flatMap { nonce in
                return nonce.delete(on: database)
            }
    }

}
extension Request {
    var nonce: NonceManager {
        .init(database: db,
              eventLoop: eventLoop)
    }
}
