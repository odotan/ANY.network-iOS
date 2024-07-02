import Foundation

final class GetRequestAccessUseCase {
    private let repository: ContactsAccessRepository
    
    init(repository: ContactsAccessRepository) {
        self.repository = repository
    }
    
    func requestAccess() async throws {
        try await repository.requestAccess()
    }
}
