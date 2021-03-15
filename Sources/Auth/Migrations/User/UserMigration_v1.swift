import Fluent

struct UserMigration_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        let roles =  Role.allCases.reduce(database.enum(Role.schema)) { $0.case($1.rawValue) }
        
        return roles.create()
            .flatMap { roles in
                return database.schema(User.schema)
                    .id()
                    .field(User.firstName, .string, .required)
                    .field(User.lastName, .string, .required)
                    .field(User.email, .string, .required)
                    .field(User.password, .string, .required)
                    .field(User.role, roles, .required)
                    .field(User.isEmailVerified, .bool, .required, .custom("DEFAULT FALSE"))
                    .field(.createdAt, .date)
                    .field(.updatedAt, .date)
                    .field(.deletedAt, .date)
                    .unique(on: User.email)
                    .create()
            }
        
        
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema).delete()
    }
}
