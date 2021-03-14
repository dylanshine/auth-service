import Vapor
import Fluent
import FluentSQLiteDriver

func databases(_ app: Application) throws {
//        app.databases.use(.postgres(
//            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
//            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
//            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
//            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
//            database: Environment.get("DATABASE_NAME") ?? "vapor_database"
//        ), as: .psql)
        
        app.databases.use(.sqlite(.memory), as: .sqlite)
}
