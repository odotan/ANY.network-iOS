import Foundation

final class SearchNameUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute(name: String) async throws -> [Contact] {
        try await repository.search(name: name)
    }
}
