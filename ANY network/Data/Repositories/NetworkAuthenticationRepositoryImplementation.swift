import Foundation

final class NetworkAuthenticationRepositoryImplementation {
    private let smsAuthenticator: SMSNetworkAuthentication
    private let facebookAuthenticator: FacebookNetworkAuthentication
    private let telegramAuthenticator: TelegramNetworkAuthentication
    private let emailAuthenticator: EmailNetworkAuthentication
    
    init(
        smsAuthenticator: SMSNetworkAuthentication,
        facebookAuthenticator: FacebookNetworkAuthentication,
        telegramAuthenticator: TelegramNetworkAuthentication,
        emailAuthenticator: EmailNetworkAuthentication
    ) {
        self.smsAuthenticator = smsAuthenticator
        self.facebookAuthenticator = facebookAuthenticator
        self.telegramAuthenticator = telegramAuthenticator
        self.emailAuthenticator = emailAuthenticator
    }
}

extension NetworkAuthenticationRepositoryImplementation: NetworkAuthenticationRepository {
    func sendCode(to phone: String) async throws -> String {
        try await smsAuthenticator.sendCode(to: phone)
    }
    
    func verifyCode(_ code: String) async throws {
        try await smsAuthenticator.verifyCode(verificationCode: code)
    }
    
    func facebookSignIn() async throws -> String {
        try await facebookAuthenticator.signIn()
    }
    
    func telegramSendCode(to phone: String) async throws {
        try await telegramAuthenticator.sendCode(to: phone)
    }
    
    func telegramVerifyCode(_ code: String) async throws {
        let _ = try await telegramAuthenticator.verify(code: code)
    }
    
    func sendEmail(to email: String) async throws {
        try await emailAuthenticator.sendSignInLink(to: email)
    }
    
    func verifyEmail(_ link: String) async throws {
        let _ = try await emailAuthenticator.verifySignInLink(link: link)
    }
}
