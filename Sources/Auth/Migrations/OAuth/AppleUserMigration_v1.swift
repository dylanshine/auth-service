import Fluent

struct AppleUserMigration_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(AppleUser.schema)
            .id()
            .field(AppleUser.appleID, .string, .required)
            .field(User.foriegnKey, .uuid, .references(User.schema, .id, onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(AppleUser.schema).delete()
    }
}
