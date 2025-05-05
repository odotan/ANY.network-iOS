import Foundation

final class EmailLoginUseCase {
    private let networkRepository: NetworkAuthenticationRepository
    
    init(networkRepository: NetworkAuthenticationRepository) {
        self.networkRepository = networkRepository
    }
    
    func sendSignInLink(to email: String) async throws {
        try await networkRepository.sendEmail(to: email)
    }
    
    func verifyEmail(_ link: String) async throws {
        let _ = try await networkRepository.verifyEmail(link)
    }
}
