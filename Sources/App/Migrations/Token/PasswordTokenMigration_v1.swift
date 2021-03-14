import Fluent

struct PasswordTokenMigration_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PasswordToken.schema)
            .id()
            .field(User.foriegnKey, .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field(.token, .string, .required)
            .field(.expiresAt, .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PasswordToken.schema).delete()
    }
}
