import Foundation

final class DetailsViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let checkIfFavoriteUseCase: CheckIfFavoriteUseCase
    private let createEditContactUseCase: CreateEditContactUseCase
    private let deleteContactUseCase: DeleteContactUseCase
    private let interactWithContactUseCase: InteractWithContactUseCase
    private let onContactChangeEvent: (ContactChangeEvent) -> Void

    init(
        contact: Contact,
        isNew: Bool,
        coordinator: MainCoordinatorProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        checkIfFavoriteUseCase: CheckIfFavoriteUseCase,
        createEditContactUseCase: CreateEditContactUseCase,
        deleteContactUseCase: DeleteContactUseCase,
        interactWithContactUseCase: InteractWithContactUseCase,
        onContactChangeEvent: @escaping (ContactChangeEvent) -> Void
    ) {
        self.state = State(contact: contact, isNew: isNew)
        self.coordinator = coordinator
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.checkIfFavoriteUseCase = checkIfFavoriteUseCase
        self.createEditContactUseCase = createEditContactUseCase
        self.deleteContactUseCase = deleteContactUseCase
        self.interactWithContactUseCase = interactWithContactUseCase
        self.onContactChangeEvent = onContactChangeEvent
        perform(action: checkIfFavoriteAction)
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.pop()
        case .showRequestNetwork:
            if state.contact.isMe {
                coordinator.showConnect(contact: state.contact)
            } else {
                coordinator.showRequestNetwork(contact: state.contact)
            }
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
        case .deleteContact:
            let prompt = ActionPrompt(
                title: "Are you sure you want to delete this contact",
                description: "This action cannot be undone",
                confirmText: "Delete",
                confirmAction: { Task { await self.deleteContact() } },
                confirmActionRole: .destructive
            )
            handle(.presentPrompt(prompt))
            break
        case .interact(let interaction):
            Task { await interact(interaction: interaction) }
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
            self?.onContactChangeEvent(.favorite)
            self?.state.contact.isFavorite = isFavourite
            self?.state.isFavorite = isFavourite
        }
    }

    private var checkIfFavoriteAction: CheckIfFavouriteAction {
        .init(value: state.contact.id, checkIfFavoriteUseCase: checkIfFavoriteUseCase) { [weak self] isFavourite in
            self?.state.contact.isFavorite = isFavourite
            self?.state.isFavorite = isFavourite

            if !(self?.state.initialFavouriteCheckDone ?? true) { // Reasign inital contact after first favourite check otherwise hasBeenModified will always evaluate to true
                self?.state.initialContact.isFavorite = isFavourite
                self?.state.initialFavouriteCheckDone = true
            }
        }
    }

    private func save() async {
        do {
            guard hasBeenModified else { return }
            removeEmptyEntries()
            state.contact = try await createEditContactUseCase.execute(contact: state.contact)
            state.initialContact = state.contact
            state.isNew = false
            onContactChangeEvent(.updated)
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

    private func removeEmptyEntries() {
        state.contact.phoneNumbers = state.contact.phoneNumbers.compactMap { $0.value.isEmpty ? nil : $0 }
        state.contact.emailAddresses = state.contact.emailAddresses.compactMap { $0.value.isEmpty ? nil : $0 }
        state.contact.postalAddresses = state.contact.postalAddresses.compactMap { $0.value.isEmpty ? nil : $0 }
        state.contact.urlAddresses = state.contact.urlAddresses.compactMap { $0.value.isEmpty ? nil : $0 }
        state.contact.socialProfiles = state.contact.socialProfiles.compactMap { $0.value.isEmpty ? nil : $0 }
        state.contact.instantMessageAddresses = state.contact.instantMessageAddresses.compactMap { $0.value.isEmpty ? nil : $0 }
    }

    private func deleteContact() async {
        do {
            try await deleteContactUseCase.execute(id: state.contact.id)
            coordinator.pop()
            onContactChangeEvent(.updated)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func interact(interaction: ContactInteraction) async {
        do {
            try await interactWithContactUseCase.extecute(interaction: interaction, type: .create)
            onContactChangeEvent(.interacted)
        } catch {
            print(error.localizedDescription)
        }
    }
}
