import Foundation

enum RegistrationType: String, CaseIterable, Codable {
    static let schema = "registration_types"
    
    case apple
    case google
    case `default`
}
