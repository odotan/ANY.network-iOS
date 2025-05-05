import Foundation

protocol NetworkAuthenticationRepository {
    func sendCode(to phone: String) async throws -> String
    func verifyCode(_ code: String) async throws
    func facebookSignIn() async throws -> String
    func telegramSendCode(to phone: String) async throws
    func telegramVerifyCode(_ code: String) async throws
    func sendEmail(to email: String) async throws
    func verifyEmail(_ link: String) async throws
}
