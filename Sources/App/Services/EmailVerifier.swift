import Vapor
import Fluent
import Queues

struct EmailVerifier {
    let database: Database
    let config: Application.Config
    let queue: Queue
    let eventLoop: EventLoop
    
    func verify(for user: User) -> EventLoopFuture<Void> {
        do {
            let token = [UInt8].generate(bits: 256)
            let emailToken = try EmailToken(userID: user.requireID(), token: SHA256.hash(token))
            let verifyUrl = url(token: token)
            let email = EmailFactory.verificationEmail(to: user.email, url: verifyUrl)
            let payload = EmailJob.Payload(email)
            
            return emailToken.create(on: database).flatMap { _ in
                return queue.dispatch(EmailJob.self, payload)
            }
            
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
    private func url(token: String) -> String {
        #"\#(config.apiURL)/api/auth/email-verification?token=\#(token)"#
    }

}
extension Request {
    var emailVerifier: EmailVerifier {
        .init(database: db,
              config: application.config,
              queue: queue,
              eventLoop: eventLoop)
    }
}
