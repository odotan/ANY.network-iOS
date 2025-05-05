import Foundation

final class SMSSendCodeUseCase {
    private let networkRepository: NetworkAuthenticationRepository
    
    init(networkRepository: NetworkAuthenticationRepository) {
        self.networkRepository = networkRepository
    }
    
    func sendCode(to phone: String) async throws -> String {
        try await networkRepository.sendCode(to: phone)
    }
    
    func verifyCode(_ code: String) async throws {
        try await networkRepository.verifyCode(code)
    }
}
