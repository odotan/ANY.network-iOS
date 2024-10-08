import Foundation

final class SearchViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let getAllContactsUseCase: GetAllContactsUseCase
    private let searchUseCase: SearchInContactUseCase

    init(coordinator: MainCoordinatorProtocol, getAllContactsUseCase: GetAllContactsUseCase, searchUseCase: SearchInContactUseCase) {
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
            Task { await search(term: term) }
        case .goBack:
            coordinator.pop()
        case .goToDetails(let contact):
            coordinator.showDetails(for: contact, isNew: false)
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

            coordinator.showDetails(for: contact, isNew: true)
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
}
