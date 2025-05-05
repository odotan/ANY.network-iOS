import Foundation

final class FetchInteractionsUseCase {
    private let repository: ContactsRepository

    init(repository: ContactsRepository) {
        self.repository = repository
    }

    func execute() async throws -> [ContactInteraction] {
        try await repository.fetchInteractions()
    }
}
