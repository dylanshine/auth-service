import SendGridKit

enum EmailFactory {
    
    static func verificationEmail(to: String, url: String) -> SendGridEmail {
        
        let to = EmailAddress(email: to)
        let from = EmailAddress(email: "developer@shinelabs.dev")
        
        let personalization = Personalization(to: [to], dynamicTemplateData: ["url" : url])
        
        return SendGridEmail(personalizations: [personalization],
                             from: from,
                             subject: "Welcome",
                             content: ["Test!"],
                             templateId: "d-79c6dc8950394c3f89565460b08dd501")
    }
    
}
