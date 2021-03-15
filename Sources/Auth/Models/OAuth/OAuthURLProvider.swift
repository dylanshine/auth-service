import Vapor
import Fluent

protocol OAuthURLProvider {
    static func authURL(state: String) throws -> String
    static var uri: URI { get }
    static var headers: HTTPHeaders { get }
}

extension OAuthURLProvider {
    static var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.contentType = .urlEncodedForm
        return headers
    }
}
