import Foundation

final class SetIsMeContactUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute(contactId: String) async throws {
        try await repository.setIsMe(contactId: contactId)
    }
}
