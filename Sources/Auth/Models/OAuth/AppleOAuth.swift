import Vapor
import JWT

extension OAuth {
    
    enum Apple: OAuthURLProvider {
        
        static func authURL(state: String) throws -> String {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "appleid.apple.com"
            components.path = "/auth/authorize"
            components.queryItems = [
                .init(name: "client_id", value: clientID),
                .init(name: "redirect_uri", value: redirectURI),
                .init(name: "scope", value: Scope.queryItemValue),
                .init(name: "state", value: state),
                .init(name: "response_type", value: ResponseType.queryItemValue),
                .init(name: "response_mode", value: "form_post")
            ]
            
            guard let url = components.url else {
                throw Abort(.internalServerError)
            }
            
            return url.absoluteString
        }
        
        static let uri: URI = .init(string: "https://appleid.apple.com/auth/token")
        
        static func authTokenRequestBody(code: String, clientSecret: String, grantType: GrantType) throws -> TokenRequestBody {
            TokenRequestBody(clientID: clientID,
                             clientSecret: clientSecret,
                             code: code,
                             redirectURI: redirectURI,
                             grantType: grantType.rawValue)
        }
        
        static var authToken: AuthToken {
            .init(clientID: clientID, teamID: teamID)
        }
        
        static var clientID: String {
            Environment.get("APPLE_CLIENT_ID")!
        }
        
        private static var redirectURI: String {
            Environment.get("APPLE_REDIRECT_URI")!
        }
        
        private static var teamID: String {
            Environment.get("APPLE_TEAM_ID")!
        }
        
    }
    
}

extension OAuth.Apple {
    
    enum Scope: String, CaseIterable {
        case name
        case email
        
        static var queryItemValue: String {
            allCases.map { $0.rawValue }.joined(separator: " ")
        }
    }
    
    enum GrantType: String {
        case auth = "authorization_code"
        case refresh = "refresh_token"
    }
    
    enum ResponseType: String, CaseIterable {
        case code
        case idToken = "id_token"
        
        static var queryItemValue: String {
            allCases.map { $0.rawValue }.joined(separator: " ")
        }
    }
    
    struct AuthResponseBody: Content {
        
        struct User: Content {
            struct Name: Content {
                let firstName: String?
                let lastName: String?
            }
            
            let name: Name
            let email: String
        }
        
        let code: String
        let idToken: String
        let state: String
        let user: User?
        
        enum CodingKeys: String, CodingKey {
            case code
            case idToken = "id_token"
            case state
            case user
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            code = try container.decode(String.self, forKey: .code)
            idToken = try container.decode(String.self, forKey: .idToken)
            state = try container.decode(String.self, forKey: .state)
            
            guard let userString = try container.decodeIfPresent(String.self, forKey: .user) else {
                user = nil
                return
            }
            
            let data = Data(userString.utf8)
            user = try? JSONDecoder().decode(User.self, from: data)
        }
        
    }
    
    struct TokenRequestBody: Content {
        
        let clientID: String
        let clientSecret: String
        let code: String
        let redirectURI: String
        let grantType: String
        
        static let defaultContentType: HTTPMediaType = .urlEncodedForm
        
        enum CodingKeys: String, CodingKey {
            case clientID = "client_id"
            case clientSecret = "client_secret"
            case code
            case grantType = "grant_type"
            case redirectURI = "redirect_uri"
        }
    }
    
    struct AuthToken: JWTPayload {
        let iss: String
        let iat: Int
        let exp: Int
        let aud: String
        let sub: String
        
        init(clientID: String,
             teamID: String,
             iat: Int = Int(Date().timeIntervalSince1970),
             aud: String = "https://appleid.apple.com",
             expirationSeconds: Int = 86400 * 180) {
            self.iat = iat
            self.aud = aud
            sub = clientID
            iss = teamID
            exp = self.iat + expirationSeconds
        }
        
        func verify(using signer: JWTSigner) throws {
            guard iss.count == 10 else {
                throw JWTError.claimVerificationFailure(name: "iss", reason: "TeamId must be your 10-character Team ID from the developer portal")
            }
            
            let lifetime = exp - iat
            guard 0...15777000 ~= lifetime else {
                throw JWTError.claimVerificationFailure(name: "exp", reason: "Expiration must be between 0 and 15777000")
            }
        }
    }
    
    struct TokenResponse: Content {
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case expiresIn = "expires_in"
            case refreshToken = "refresh_token"
            case idToken = "id_token"
        }
        
        let accessToken: String
        let tokenType: String
        let expiresIn: Int
        let refreshToken: String
        let idToken: String
    }
}
