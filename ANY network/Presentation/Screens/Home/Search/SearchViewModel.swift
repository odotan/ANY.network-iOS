import Foundation

final class SearchViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let getAllContactsUseCase: GetAllContactsUseCase
    private let searchUseCase: SearchInContactUseCase
    private let interactWithContactUseCase: InteractWithContactUseCase
    private let onContactChangeEvent: (ContactChangeEvent) -> Void
    
    init(
        coordinator: MainCoordinatorProtocol,
        getAllContactsUseCase: GetAllContactsUseCase,
        searchUseCase: SearchInContactUseCase,
        interactWithContactUseCase: InteractWithContactUseCase,
        onContactChangeEvent: @escaping (ContactChangeEvent) -> Void
    ) {
        self.state = State()
        self.coordinator = coordinator
        self.getAllContactsUseCase = getAllContactsUseCase
        self.searchUseCase = searchUseCase
        self.interactWithContactUseCase = interactWithContactUseCase
        self.onContactChangeEvent = onContactChangeEvent
    }
    
    func handle(_ event: Event) {
        switch event {
        case .getAll:
            Task { await getAll() }
        case .updateSearchTerm(let term):
            Task { await search(term: term) }
        case .goBack:
            coordinator.pop()
        case .goToDetails(let contact):
            coordinator.showDetails(
                for: contact,
                isNew: false,
                anchor: nil,
                onContactChangeEvent: onContactChangeEvent
            )
        case .addContact:
            print("Add it with searched term:", state.searchTerm)
            var contact = Contact(id: "")
            if state.searchTerm.isEmail {
                contact.emailAddresses.append(LabeledValue(id: "", label: "home", value: state.searchTerm))
            } else if state.searchTerm.isPhoneNumber {
                contact.phoneNumbers.append(LabeledValue(id: "", label: "home", value: state.searchTerm))
            } else {
                contact.givenName = state.searchTerm
            }

            coordinator.showDetails(
                for: contact,
                isNew: true,
                anchor: nil,
                onContactChangeEvent: onContactChangeEvent
            )
        case .interact(let interaction):
            Task { await interact(interaction: interaction) }
        }
    }
}

extension SearchViewModel {
    private func getAll() async {
        do {
            state.list = try await getAllContactsUseCase.execute()
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func search(term: String) async {
        defer {
            state.searchTerm = term
        }

        do {
            if !term.isEmpty {
                state.list = try await searchUseCase.execute(term: term)
            } else {
                await getAll()
            }
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }

    private func interact(interaction: ContactInteraction) async {
        do {
            try await interactWithContactUseCase.extecute(interaction: interaction, type: .create)
            print("interaction Created")
        } catch {
            print(error.localizedDescription)
        }
    }
}
