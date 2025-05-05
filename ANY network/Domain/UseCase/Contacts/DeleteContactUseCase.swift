import Foundation

final class DeleteContactUseCase {
    private let repository: ContactsRepository

    init(repository: ContactsRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.deleteContact(id: id)
    }
}
