import Foundation
import UIKit // Move UIApplication.shared.open in seperate struct

final class DetailsViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let checkIfFavoriteUseCase: CheckIfFavoriteUseCase
    
    init(
        contact: Contact,
        coordinator: MainCoordinatorProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        checkIfFavoriteUseCase: CheckIfFavoriteUseCase
    ) {
        self.state = State(contact: contact)
        self.coordinator = coordinator
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.checkIfFavoriteUseCase = checkIfFavoriteUseCase
        
        handle(.checkIfFavorite)
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.pop()
        case .starPressed:
            Task { await toggleFavorite() }
        case .checkIfFavorite:
            Task { await checkIfFavorite() }
        case .performAction(let action):
            perform(action: action)
        case .presentPrompt(let prompt):
            state.actionPrompt = prompt
        }
    }
}

extension DetailsViewModel {
    func toggleFavorite() async {
        do {
            state.isFavorite = try await toggleFavoriteUseCase.execute(state.contact.id)
        } catch {
            print("Error", error.localizedDescription)
        }
    }
    
    func checkIfFavorite() async {
        do {
            state.isFavorite = try await checkIfFavoriteUseCase.execute(state.contact.id)
        } catch {
            print("Error", error.localizedDescription)
        }
    }
    
    func perform(action: Action) {
        switch action {
        case .phone:
            guard let phone = state.contact.phoneNumbers.first else { return }
            
            handle(.presentPrompt(.init(title: "Do you want to call?", description: "You are about to call \(state.contact.fullName)") {
                let tel = "tel://"
                let formattedString = tel + phone.value
                guard let url = URL(string: formattedString) else { return }
                UIApplication.shared.open(url)
            }))
        }
    }
}
