import Vapor
import Fluent

final class GoogleUser: Model {
    static let schema = "google_users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: GoogleUser.googleID)
    var googleID: String
    
    @Parent(key: User.foriegnKey)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil,
         googleID: String,
         userID: UUID) {
        self.id = id
        self.googleID = googleID
        self.$user.id = userID
    }
}

extension GoogleUser {
    static let googleID: FieldKey = "google_id"
}

extension GoogleUser: OAuthModel {
    static var userKeyPath: KeyPath<GoogleUser, ParentProperty<GoogleUser, User>> {
        \GoogleUser.$user
    }
    
    static var idKeyPath: KeyPath<GoogleUser, FieldProperty<GoogleUser, String>> {
        \GoogleUser.$googleID
    }
    
    convenience init(id: String, userID: UUID) {
        self.init()
        googleID = id
        $user.id = userID
    }
}
