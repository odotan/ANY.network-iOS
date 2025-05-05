import Foundation

final class CheckIfFavoriteUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute(_ id: String) async throws -> Bool {
        try await repository.checkIfFavorite(contactId: id)
    }
}
