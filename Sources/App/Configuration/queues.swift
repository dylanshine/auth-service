import Vapor
import Queues
import QueuesRedisDriver

func queues(_ app: Application) throws {
    try app.queues.use(.redis(url: app.config.redisURL))
    
    app.queues.add(EmailJob())
    
}
