import Vapor
import Queues
import Fluent

struct PasswordResetter {
    let database: Database
    let queue: Queue
    let eventLoop: EventLoop
    let config: Application.Config
    
    /// Sends a email to the user with a reset-password URL
    func reset(for user: User) -> EventLoopFuture<Void> {
        do {
            let token = [UInt8].generate(bits: 256)
            let resetPasswordToken = try PasswordToken(userID: user.requireID(), token: SHA256.hash(token))
//            let url = resetURL(for: token)
//            let email = Email.resetPassword(resetURL: url)
            return resetPasswordToken.create(on: database).flatMap {
                return eventLoop.makeSucceededFuture(())
//                queue.dispatch(EmailJob.self, .init(email, to: user.email))
            }
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
    private func resetURL(for token: String) -> String {
        "\(config.apiURL)/auth/reset-password?token=\(token)"
    }
}

extension Request {
    var passwordResetter: PasswordResetter {
        .init(database: db, queue: queue, eventLoop: eventLoop, config: application.config)
    }
}
