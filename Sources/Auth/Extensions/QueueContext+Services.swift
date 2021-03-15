import Queues
import SendGridKit

extension QueueContext {
    var sendGrid: SendGridClient {
        let httpClient = application.http.client.shared
        let apiKey = application.config.sendgridAPIKey
        return SendGridClient(httpClient: httpClient, apiKey: apiKey)
    }
}
