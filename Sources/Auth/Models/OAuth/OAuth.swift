import Vapor
import JWT

enum OAuth {
    static let platformKey = "platform"
    static let codeKey = "code"
    static let errorKey = "error"
    static let stateKey = "state"
    
    enum Platform: String, Codable {
        case web
        case ios
        case android
        case desktop
    }
    
    struct State: JWTPayload {
        let platform: Platform
        let nounce: String
        let expiration: ExpirationClaim
        
        init(platform: Platform,
             nonce: String,
             expirationDate: Date = .oAuthStateTokenLifetime) {
            self.platform = platform
            self.nounce = nonce
            self.expiration = ExpirationClaim(value: expirationDate)
        }
        
        func verify(using signer: JWTSigner) throws {
            try expiration.verifyNotExpired()
        }
    }
}
