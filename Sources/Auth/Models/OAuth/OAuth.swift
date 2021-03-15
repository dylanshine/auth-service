import JWT

enum OAuth {
    static let clientKey = "client"
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
        let client: Platform
        func verify(using signer: JWTSigner) throws {}
    }
}
