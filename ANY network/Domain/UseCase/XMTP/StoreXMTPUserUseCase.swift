import Foundation

final class StoreXMTPUserUseCase {
    private let repository: FirebaseRepository
    
    init(repository: FirebaseRepository) {
        self.repository = repository
    }
    
    func execute(user: XMTPUser) async throws {
        try await repository.storeXMTPUser(user: user)
    }
} 
