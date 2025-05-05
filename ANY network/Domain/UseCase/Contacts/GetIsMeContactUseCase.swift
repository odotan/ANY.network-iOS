import Foundation

final class GetIsMeContactUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> Contact? {
        try await repository.getIsMeContact()
    }
}
