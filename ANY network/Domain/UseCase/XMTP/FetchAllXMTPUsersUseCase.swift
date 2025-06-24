import Foundation

final class FetchAllXMTPUsersUseCase {
    private let repository: FirebaseRepository
    
    init(repository: FirebaseRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [XMTPUser] {
        return try await repository.fetchAllXMTPUsers()
    }
} 
