import Vapor

func migrations(_ app: Application) throws {
    UserMigrations.add(app.migrations)
    TokenMigrations.add(app.migrations)
    try app.autoMigrate().wait()
}
