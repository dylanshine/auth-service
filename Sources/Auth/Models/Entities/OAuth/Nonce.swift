import Vapor
import Fluent

final class Nonce: Model {
    static var schema: String = "nonces"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: .nonce)
    var nonce: String
    
    @Field(key: .expiresAt)
    var expiresAt: Date
    
    init() {}
    
    init(id: UUID? = nil, nonce: String, expiresAt: Date = .resetPasswordTokenLifetime) {
        self.id = id
        self.nonce = nonce
        self.expiresAt = expiresAt
    }
    
}
