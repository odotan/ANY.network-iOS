import Foundation

final class DetailsViewModel: ViewModel {
    @Published private(set) var state: State
    let contact: Contact
    private let coordinator: MainCoordinatorProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    
    init(contact: Contact, coordinator: MainCoordinatorProtocol, toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.state = .idle
        self.contact = contact
        self.coordinator = coordinator
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.pop()
        }
    }
}

extension DetailsViewModel {
    func toggleFavorite() async {
        do {
            try await toggleFavoriteUseCase.execute(contact.id)
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
}
