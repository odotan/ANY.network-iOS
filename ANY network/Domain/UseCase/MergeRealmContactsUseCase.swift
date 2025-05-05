import Foundation

final class MergeRealmContactsUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.mergeRealmIntoNativeContacts()
    }
}
