import Fluent

struct EmailTokenMigration_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(EmailToken.schema)
            .id()
            .field(User.foriegnKey, .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field(.token, .string, .required)
            .field(.expiresAt, .datetime, .required)
            .unique(on: User.foriegnKey)
            .unique(on: .token)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(EmailToken.schema).delete()
    }
}
