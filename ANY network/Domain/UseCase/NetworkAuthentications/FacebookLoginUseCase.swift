import Foundation

final class FacebookLoginUseCase {
    private let networkRepository: NetworkAuthenticationRepository
    
    init(networkRepository: NetworkAuthenticationRepository) {
        self.networkRepository = networkRepository
    }
    
    func signIn() async throws -> String {
        try await networkRepository.facebookSignIn()
    }
}
