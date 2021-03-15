import JWT

enum OAuth {
    static let platform = "platform"
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
        let expiration: ExpirationClaim
        
        init(platform: Platform,
             expirationDate: Date = .oauthStateTokenLifetime) {
            self.platform = platform
            self.expiration = ExpirationClaim(value: expirationDate)
        }
        
        func verify(using signer: JWTSigner) throws {
            try expiration.verifyNotExpired()
        }
    }
}
