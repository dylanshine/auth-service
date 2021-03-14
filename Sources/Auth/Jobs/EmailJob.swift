
import Vapor
import Queues
import SendGridKit

struct EmailPayload: Codable {
    let email: SendGridEmail
    
    init(_ email: SendGridEmail) {
        self.email = email
    }
}

struct EmailJob: Job {
    typealias Payload = EmailPayload
    
    func dequeue(_ context: QueueContext, _ payload: EmailPayload) -> EventLoopFuture<Void> {
        let httpClient = context.application.http.client.shared
        let apiKey = context.application.config.sendgridAPIKey
        let sg = SendGridClient(httpClient: httpClient, apiKey: apiKey)
        
        do {
            return try sg.send(email: payload.email, on: context.eventLoop)
        } catch {
            context.logger.report(error: error)
            return context.eventLoop.makeFailedFuture(error)
        }
    }
}
