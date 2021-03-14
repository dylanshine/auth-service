import Vapor

func middleware(_ app: Application) throws {
    app.middleware.use(CORSMiddleware())
}
