import Vapor

struct LoginResponse: Content {
    let user: User.DTO
    let accessToken: String
    let refreshToken: String
}
