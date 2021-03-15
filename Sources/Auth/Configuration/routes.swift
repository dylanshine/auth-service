import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api","v1")
    
    try AuthenticationController().boot(routes: api)
    try GoogleOAuthController().boot(routes: api)
    try AppleOAuthController().boot(routes: api)

}
