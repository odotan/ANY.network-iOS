import Foundation

final class ToggleFavoriteUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute(_ id: String) async throws {
        try await repository.toggleFavorite(contactId: id)
    }
}
