import Foundation

final class CreateEditContactUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    @discardableResult
    func execute(contact: Contact) async throws -> Contact {
        try await repository.createEdit(contact: contact)
    }
}
