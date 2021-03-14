import Vapor
import Fluent

final class User: Model, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: User.firstName)
    var firstName: String
    
    @Field(key: User.lastName)
    var lastName: String
    
    @Field(key: User.email)
    var email: String
    
    @Field(key: User.password)
    var password: String
    
    @Enum(key: User.registrationType)
    var registrationType: RegistrationType
    
    @Enum(key: User.role)
    var role: Role
    
    @Field(key: User.isEmailVerified)
    var isEmailVerified: Bool
    
    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: .deletedAt, on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil,
         firstName: String,
         lastName: String,
         email: String,
         passwordHash: String,
         registrationType: RegistrationType = .default,
         role: Role = .free,
         isEmailVerified: Bool = false) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = passwordHash
        self.registrationType = registrationType
        self.role = role
        self.isEmailVerified = isEmailVerified
    }
}
