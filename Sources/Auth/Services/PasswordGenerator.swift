enum PasswordGenerator {
    static let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?;,&%$@#^*~"
    static func generatePassword() -> String {
        let length = Int.random(in: 8...12)
        return String((0..<length).compactMap{ _ in characters.randomElement() })
    }
}
