import Vapor
import Fluent

final class RefreshToken: Model {
    static let schema = "refresh_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: User.foriegnKey)
    var user: User
    
    @Field(key: .token)
    var token: String
    
    @Field(key: .expiresAt)
    var expiresAt: Date
    
    @Field(key: .issuedAt)
    var issuedAt: Date
    
    init() {}
    
    init(id: UUID? = nil,
         token: String,
         userID: UUID,
         expiresAt: Date = .resetTokenLifetime,
         issuedAt: Date = Date()) {
        self.id = id
        self.token = token
        self.$user.id = userID
        self.expiresAt = expiresAt
        self.issuedAt = issuedAt
    }
}
