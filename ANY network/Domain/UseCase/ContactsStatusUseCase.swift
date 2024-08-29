import Foundation

final class ContactsStatusUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func getStatus() async throws -> ContactServiceType {
        try await repository.getStatus()
    }
    
    func update(status: ContactServiceType) async throws {
        try await repository.update(status: status)
    }
}
