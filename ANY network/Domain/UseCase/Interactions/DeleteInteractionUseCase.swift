import Foundation

final class DeleteInteractionUseCase {
    private let repository: ContactsRepository

    init(repository: ContactsRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.deleteInteraction(id: id)
    }
}
