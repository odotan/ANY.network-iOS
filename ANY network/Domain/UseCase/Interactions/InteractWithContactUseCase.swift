import Foundation

enum InteractionActionType {
    case create, move
}

final class InteractWithContactUseCase {
    private let repository: ContactsRepository

    init(repository: ContactsRepository) {
        self.repository = repository
    }

    func extecute(interaction: ContactInteraction, type: InteractionActionType) async throws {
        try await repository.saveInteraction(interaction: interaction, type: type)
    }
}
