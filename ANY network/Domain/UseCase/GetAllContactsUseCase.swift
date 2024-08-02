import Foundation

final class GetAllContactsUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Contact] {
        try await repository.getAll()
    }
}
