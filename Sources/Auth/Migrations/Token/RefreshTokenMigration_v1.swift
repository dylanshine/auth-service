import Fluent

struct RefreshTokenMigration_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RefreshToken.schema)
            .id()
            .field(.token, .string, .required)
            .field(User.foriegnKey, .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field(.expiresAt, .datetime, .required)
            .field(.issuedAt, .datetime, .required)
            .unique(on: .token)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RefreshToken.schema).delete()
    }
}
