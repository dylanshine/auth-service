import Vapor
import Fluent

struct OAuthHandler {
    let database: Database
    let password: Request.Password
    let eventLoop: EventLoop
    
    
    
    func handle<T: OAuthModel>(_ type: T.Type,
                               id: String,
                               email: String,
                               firstName: String,
                               lastName: String) -> EventLoopFuture<User> {
        return type.query(on: database)
            .with(T.userKeyPath)
            .filter(T.idKeyPath == id)
            .first()
            .flatMap { oAuthModel in
                
                if let oAuthModel = oAuthModel {
                    return eventLoop.makeSucceededFuture(oAuthModel.user)
                }
                
                return User.query(on: database)
                    .filter(\.$email == email)
                    .first()
                    .flatMap { user in
                        if let user = user {
                            do {
                                let oAuthUser = T(id: id, userID: try user.requireID())
                                return oAuthUser.create(on: database).transform(to: user)
                            } catch {
                                return eventLoop.makeFailedFuture(error)
                            }
                        }
                        
                        return password
                            .async
                            .hash(PasswordGenerator.generatePassword())
                            .map { passwordHash in
                                User(firstName: firstName,
                                     lastName: lastName,
                                     email: email,
                                     passwordHash: passwordHash,
                                     isEmailVerified: true)
                            }.flatMap { user in
                                return database.transaction { db -> EventLoopFuture<User> in
                                    return user.create(on: db).flatMap {
                                        do {
                                            let oAuthUser = T(id: id, userID: try user.requireID())
                                            return oAuthUser.create(on: db).transform(to: user)
                                        } catch {
                                            return eventLoop.makeFailedFuture(error)
                                        }
                                    }
                                }
                            }
                    }
            }
    }
}

extension Request {
    var oAuthUserHandler: OAuthHandler {
        .init(database: db,
              password: password,
              eventLoop: eventLoop)
    }
}
