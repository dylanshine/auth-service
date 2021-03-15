import Foundation

extension Date {
    static var emailTokenLifetime: Date {
        Date().addingTimeInterval(EMAIL_TOKEN_LIFETIME)
    }
    
    static var resetPasswordTokenLifetime: Date {
        Date().addingTimeInterval(RESET_PASSWORD_TOKEN_LIFETIME)
    }
    
    static var resetTokenLifetime: Date {
        Date().addingTimeInterval(REFRESH_TOKEN_LIFETIME)
    }
    
    static var accessTokenLifetime: Date {
        Date().addingTimeInterval(ACCESS_TOKEN_LIFETIME)
    }

    static var oauthStateTokenLifetime: Date {
        Date().addingTimeInterval(OAUTH_STATE_TOKEN_LIFETIME)
    }
}
