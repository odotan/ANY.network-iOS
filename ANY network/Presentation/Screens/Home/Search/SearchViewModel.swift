import Foundation

final class SearchViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let getAllContactsUseCase: GetAllContactsUseCase
    private let searchUseCase: SearchNameUseCase
    
    init(coordinator: MainCoordinatorProtocol, getAllContactsUseCase: GetAllContactsUseCase, searchUseCase: SearchNameUseCase) {
        self.state = State()
        self.coordinator = coordinator
        self.getAllContactsUseCase = getAllContactsUseCase
        self.searchUseCase = searchUseCase
    }
    
    func handle(_ event: Event) {
        switch event {
        case .getAll:
            Task { await getAll() }
        case .updateSearchTerm(let term):
            Task { await search(name: term) }
        case .goBack:
            coordinator.pop()
        case .goToDetails(let contact):
            coordinator.showDetails(for: contact)
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

            coordinator.showDetails(for: contact)
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
    
    private func search(name: String) async {
        defer {
            state.searchTerm = name
        }
        
        guard name.count > 2 || name.count < state.searchTerm.count else { return }

        do {
            if !name.isEmpty {
                state.list = try await searchUseCase.execute(name: name)
            } else {
                await getAll()
            }
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
}
