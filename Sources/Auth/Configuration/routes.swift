import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api")
    
    try AuthenticationController().boot(routes: api)
}
