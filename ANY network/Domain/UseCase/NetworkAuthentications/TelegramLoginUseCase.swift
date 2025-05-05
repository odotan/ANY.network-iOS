import Foundation

final class TelegramLoginUseCase {
    private let networkRepository: NetworkAuthenticationRepository
    
    init(networkRepository: NetworkAuthenticationRepository) {
        self.networkRepository = networkRepository
    }
    
    func sendCode(to phone: String) async throws {
        try await networkRepository.telegramSendCode(to: phone)
    }
    
    func verifyCode(_ code: String) async throws {
        try await networkRepository.telegramVerifyCode(code)
    }
}
