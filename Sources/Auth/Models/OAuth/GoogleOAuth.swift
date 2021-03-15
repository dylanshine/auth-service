import Vapor

extension OAuth {
    enum Google {
        
        private enum Scope: String, CaseIterable {
            case email
            case profile
            
            static var queryItemValue: String {
                allCases.map { $0.rawValue }.joined(separator: " ")
            }
        }
        
        private static let accessTokenURL: String = "https://www.googleapis.com/oauth2/v4/token"
        static let accessTokenURI: URI = .init(string: accessTokenURL)
        
        static func authURL(state: String) throws -> String {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "accounts.google.com"
            components.path = "/o/oauth2/auth"
            components.queryItems = [
                clientIDItem,
                redirectURIItem,
                scopeItem,
                stateItem(state: state),
                codeResponseTypeItem
            ]
            
            guard let url = components.url else {
                throw Abort(.internalServerError)
            }
            
            return url.absoluteString
        }
        
        static func accessTokenRequestBody(code: String) -> AccessTokenRequestBody {
            .init(code: code, clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI)
        }
        
        static let accessTokenHeaders: HTTPHeaders = {
            var headers = HTTPHeaders()
            headers.contentType = .urlEncodedForm
            return headers
        }()
        
        private static func stateItem(state: String) -> URLQueryItem {
            .init(name: "state", value: state)
        }
        
        private static var clientIDItem: URLQueryItem {
            .init(name: "client_id", value: clientID)
        }
        
        private static var redirectURIItem: URLQueryItem {
            .init(name: "redirect_uri", value: redirectURI)
        }
        
        private static var scopeItem: URLQueryItem {
            .init(name: "scope", value: Scope.queryItemValue)
        }
        
        private static var codeResponseTypeItem: URLQueryItem {
            .init(name: "response_type", value: "code")
        }
        
        private static var clientID: String {
            Environment.get("GOOGLE_CLIENT_ID")!
        }
        
        private static var clientSecret: String {
            Environment.get("GOOGLE_CLIENT_SECRET")!
        }
        
        private static var redirectURI: String {
            Environment.get("GOOGLE_REDIRECT_URI")!
        }
        
        struct AccessTokenRequestBody: Content {
            let code: String
            let clientID: String
            let clientSecret: String
            let redirectURI: String
            let grantType: String = "authorization_code"
            
            static let defaultContentType: HTTPMediaType = .urlEncodedForm
            
            enum CodingKeys: String, CodingKey {
                case code
                case clientID = "client_id"
                case clientSecret = "client_secret"
                case redirectURI = "redirect_uri"
                case grantType = "grant_type"
            }
        }
        
        struct TokenResponse: Content {
            let accessToken: String
            let idToken: String
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case idToken = "id_token"
            }
        }
    }
}


