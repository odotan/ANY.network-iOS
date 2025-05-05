import Foundation

final class MyProfileViewModel: ViewModel {
    @Published private(set) var state: State

    private let coordinator: MainCoordinatorProtocol
    private let getAllContactsUseCase: GetAllContactsUseCase
    private let searchUseCase: SearchInContactUseCase
    private let setIsMeContactUseCase: SetIsMeContactUseCase
    private let onDismiss: () -> Void
    
    init(
        coordinator: MainCoordinatorProtocol,
        getAllContactsUseCase: GetAllContactsUseCase,
        searchUseCase: SearchInContactUseCase,
        setIsMeContactUseCase: SetIsMeContactUseCase,
        onDismiss: @escaping () -> Void
    ) {
        self.state = State()
        self.coordinator = coordinator
        self.getAllContactsUseCase = getAllContactsUseCase
        self.searchUseCase = searchUseCase
        self.setIsMeContactUseCase = setIsMeContactUseCase
        self.onDismiss = onDismiss
    }
    
    func handle(_ event: Event) {
        switch event {
        case .getAll:
            Task { await getAll() }
        case .updateSearchTerm(let term):
            Task { await search(term: term) }
        case .goBack:
            coordinator.pop()
        case .setIsSearching(let isSearching):
            state.isSearching = isSearching
        case .select(let contact):
            state.selected = contact
            handle(.setIsAlertPresented(true))
        case .setIsAlertPresented(let isPresented):
            state.isAlertPresented = isPresented
        case .setContactConfirmation:
            if let contact = state.selected {
                Task { await setIsMe() }
            }
        case .setDismiss:
            onDismiss()
        }
    }
}

extension MyProfileViewModel {
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
        print(term)
        do {
            if !term.isEmpty {
                state.list = try await searchUseCase.execute(name: term)
            } else {
                await getAll()
            }
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func setIsMe() async {
        guard let contact = state.selected else { return }
        
        do {
            try await setIsMeContactUseCase.execute(contactId: contact.id)
            handle(.goBack)
            handle(.setDismiss)
        } catch {
            print("Error setting is me contact:", error.localizedDescription)
        }
    }
}
