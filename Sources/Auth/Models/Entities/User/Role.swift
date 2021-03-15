import Foundation

enum Role: String, CaseIterable, Codable {
    static let schema = "roles"
    
    case basic
    case premium
    case administrative
}
