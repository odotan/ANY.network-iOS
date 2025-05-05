import Foundation

final class FetchInteractionUseCase {
    private let repository: ContactsRepository

    init(repository: ContactsRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> ContactInteraction? {
        try await repository.fetchInteraction(id: id)
    }
}
