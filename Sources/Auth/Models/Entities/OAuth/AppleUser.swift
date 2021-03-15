import Vapor
import Fluent

final class AppleUser: Model {
    static let schema = "apple_users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: AppleUser.appleID)
    var appleID: String
    
    @Parent(key: User.foriegnKey)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil,
         appleID: String,
         userID: UUID) {
        self.id = id
        self.appleID = appleID
        self.$user.id = userID
    }
}

extension AppleUser {
    static let appleID: FieldKey = "apple_id"
}

extension AppleUser: OAuthModel {
    static var userKeyPath: KeyPath<AppleUser, ParentProperty<AppleUser, User>> {
        \AppleUser.$user
    }
    
    static var idKeyPath: KeyPath<AppleUser, FieldProperty<AppleUser, String>> {
        \AppleUser.$appleID
    }
    
    convenience init(id: String, userID: UUID) {
        self.init()
        appleID = id
        $user.id = userID
    }
}
