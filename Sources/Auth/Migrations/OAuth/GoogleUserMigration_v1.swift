import Fluent

struct GoogleUserMigration_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(GoogleUser.schema)
            .id()
            .field(GoogleUser.googleID, .string, .required)
            .field(User.foriegnKey, .uuid, .references(User.schema, .id, onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(GoogleUser.schema).delete()
    }
}
