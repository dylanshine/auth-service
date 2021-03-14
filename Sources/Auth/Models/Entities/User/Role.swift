import Foundation

enum Role: String, CaseIterable, Codable {
    static let schema = "roles"
    
    case free
    case paid
    case admin
}
