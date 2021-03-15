import Vapor
import Fluent
import JWT
import XSJWT

struct TokenGenerator {
    let database: Database
    let jwt: Request.JWT
    let eventLoop: EventLoop
    
    func response(for user: User) -> EventLoopFuture<TokenResponse> {
        do {
            let token = [UInt8].generate(bits: 256)
            
            let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
            
            return refreshToken.create(on: database)
                .flatMapThrowing {
                
                    let payload = try Payload(user: user)
                    
                    return try TokenResponse(
                        user: User.DTO(user: user),
                        accessToken: jwt.sign(payload),
                        refreshToken: token)
                }
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }

}
extension Request {
    var tokenGenerator: TokenGenerator {
        .init(database: db,
              jwt: jwt,
              eventLoop: eventLoop)
    }
}
