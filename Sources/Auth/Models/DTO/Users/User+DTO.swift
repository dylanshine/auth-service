import Vapor
import XSJWT

extension User {
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    struct DTO: Content {
        let id: UUID?
        let fullName: String
        let email: String
        let role: Role
        
        init(id: UUID? = nil,
             fullName: String,
             email: String,
             role: Role) {
            self.id = id
            self.fullName = fullName
            self.email = email
            self.role = role
        }
        
        init(user: User) {
            self.init(id: user.id,
                      fullName: user.fullName,
                      email: user.email,
                      role: user.role)
        }
    }
}

extension Payload {
    init(user: User) throws {
        self.init(id: try user.requireID(),
                  name: user.fullName,
                  email: user.email,
                  isAdmin: user.role == .administrative,
                  expirationDate: .accessTokenLifetime)
    }
}
