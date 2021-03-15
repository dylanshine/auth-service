import Vapor

struct TokenResponse: Content {
    let user: User.DTO
    let accessToken: String
    let refreshToken: String
}
