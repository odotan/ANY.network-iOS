import Foundation

final class GetContactUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute(with identifier: String) async throws -> Contact? {
        try await repository.getContact(withIdentifier: identifier)
    }
}
