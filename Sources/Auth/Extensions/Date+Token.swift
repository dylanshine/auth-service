import Foundation

extension Date {
    static var emailTokenLifetime: Date {
        Date().addingTimeInterval(Constants.EMAIL_TOKEN_LIFETIME)
    }
    
    static var resetPasswordTokenLifetime: Date {
        Date().addingTimeInterval(Constants.RESET_PASSWORD_TOKEN_LIFETIME)
    }
    
    static var resetTokenLifetime: Date {
        Date().addingTimeInterval(Constants.REFRESH_TOKEN_LIFETIME)
    }
    
    static var accessTokenLifetime: Date {
        Date().addingTimeInterval(Constants.ACCESS_TOKEN_LIFETIME)
    }

}
