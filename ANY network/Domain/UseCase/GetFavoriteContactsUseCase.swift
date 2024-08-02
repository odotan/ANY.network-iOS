import Foundation

final class GetFavoriteContactsUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Contact] {
        try await repository.getFavoriteContacts()
    }
}
