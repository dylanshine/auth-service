import Vapor

struct RegisterRequest: Content {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let confirmPassword: String
}

extension RegisterRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("firstName", as: String.self, is: .count(3...))
        validations.add("lastName", as: String.self, is: .count(3...))
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User {
    convenience init(from register: RegisterRequest, passwordHash: String) {
        self.init(firstName: register.firstName,
                  lastName: register.lastName,
                  email: register.email,
                  passwordHash: passwordHash)
    }
}
