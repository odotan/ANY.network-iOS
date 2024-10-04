import Foundation

final class DetailsViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let checkIfFavoriteUseCase: CheckIfFavoriteUseCase
    private let createEditContactUseCase: CreateEditContactUseCase
    
    init(
        contact: Contact,
        isNew: Bool,
        coordinator: MainCoordinatorProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        checkIfFavoriteUseCase: CheckIfFavoriteUseCase,
        createEditContactUseCase: CreateEditContactUseCase
    ) {
        self.state = State(contact: contact, isNew: isNew)
        self.coordinator = coordinator
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.checkIfFavoriteUseCase = checkIfFavoriteUseCase
        self.createEditContactUseCase = createEditContactUseCase
        perform(action: checkIfFavoriteAction)
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.pop()
        case .performAction(let action):
            perform(action: action)
        case .presentPrompt(let prompt):
            state.actionPrompt = prompt
        case .setIsEditing(let isEditing):
            state.isEditing = isEditing
        case .save:
            handle(.setIsEditing(false))
            Task { await save() }
        case .discardChanges(let shouldDiscard):
            state.discardChanges = shouldDiscard
        case .selectedPickerPhotoChanged(let newSelection):
            state.selectedPhoto = newSelection
        case .profileImageDataChanged(let newData):
            state.contactImageData = newData
            state.contact.imageData = newData
            state.contact.imageDataAvailable = true
        }
    }
}

extension DetailsViewModel {
    var createEditVM: EditContactViewModel {
        .init(state: .init(get: { self.state }, set: { self.state = $0 }))
    }
    
    var hasBeenModified: Bool {
        !state.initialContact.isLike(state.contact)
    }
    
    var toggleFavoriteAction: ToggleFavouriteAction {
        .init(value: state.contact.id, toggleFavoriteUseCase: toggleFavoriteUseCase) { [weak self] isFavourite in
            self?.state.contact.isFavorite = isFavourite
            self?.state.isFavorite = isFavourite
        }
    }

    private var checkIfFavoriteAction: CheckIfFavouriteAction {
        .init(value: state.contact.id, checkIfFavoriteUseCase: checkIfFavoriteUseCase) { [weak self] isFavourite in
            self?.state.contact.isFavorite = isFavourite
            self?.state.isFavorite = isFavourite
        }
    }

    private func save() async {
        do {
            state.contact = try await createEditContactUseCase.execute(contact: state.contact)
        } catch {
            print("Error", error.localizedDescription)
        }
    }
    
    private func perform(action: any ContactAction) {
        do {
            try action.performAction()
        } catch {
            print(error.localizedDescription)
        }
    }
}
