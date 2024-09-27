import Foundation

final class SearchInContactUseCase {
    private let repository: ContactsRepository

    init(repository: ContactsRepository) {
        self.repository = repository
    }

    func execute(term: String) async throws -> [Contact] {
        try await repository.search(term: term)
    }
}
