import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    try server(app)
    try jwt(app)
    try databases(app)
    try migrations(app)
    try routes(app)
    try queues(app)

}
