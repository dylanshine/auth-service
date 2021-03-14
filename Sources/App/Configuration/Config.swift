import Vapor

extension Application {
    struct Config {
        let apiURL: String
        let sendgridAPIKey: String
        let redisURL: String
        let jwksFile: String
        
        static var environment: Config {
            guard let apiURL = Environment.get("API_URL"),
                  let sendgridAPIKey = Environment.get("SENDGRID_API_KEY"),
                  let redisURL = Environment.get("REDIS_URL"),
                  let jwksFile = Environment.get("JWKS_KEYPAIR_FILE") else {
                    fatalError("Please add app configuration to environment variables")
            }
            
            return .init(apiURL: apiURL,
                         sendgridAPIKey: sendgridAPIKey,
                         redisURL: redisURL,
                         jwksFile: jwksFile)
        }
    }
    
    struct ConfigKey: StorageKey {
        typealias Value = Config
    }
    
    var config: Config {
        get { storage[ConfigKey.self] ?? .environment }
        set { storage[ConfigKey.self] = newValue }
    }
    
}
