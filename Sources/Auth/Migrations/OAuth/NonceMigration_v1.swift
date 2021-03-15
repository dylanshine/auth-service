import Fluent

struct NonceMigration_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Nonce.schema)
            .id()
            .field(.nonce, .string, .required)
            .field(.expiresAt, .datetime, .required)
            .unique(on: .nonce)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Nonce.schema).delete()
    }
}
