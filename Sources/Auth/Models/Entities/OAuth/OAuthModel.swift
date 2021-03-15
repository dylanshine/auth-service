import Fluent
import Vapor

protocol OAuthModel: Model {
    var user: User { get }
    static var userKeyPath: KeyPath<Self, ParentProperty<Self, User>> { get }
    static var idKeyPath: KeyPath<Self, FieldProperty<Self, String>> { get }
    init(id: String, userID: UUID)
    
}
