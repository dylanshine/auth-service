import Vapor
import Fluent

final class PasswordToken: Model {
    static var schema: String = "password_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: User.foriegnKey)
    var user: User

    @Field(key:.token)
    var token: String
    
    @Field(key: .expiresAt)
    var expiresAt: Date
    
    init() {}
    
    init(id: UUID? = nil, userID: UUID, token: String, expiresAt: Date = .resetPasswordTokenLifetime) {
        self.id = id
        self.$user.id = userID
        self.token = token
        self.expiresAt = expiresAt
    }
    
}
