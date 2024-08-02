import Foundation

final class GetRequestAccessUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func requestAccess() async throws {
        try await repository.requestAccess()
    }
}
