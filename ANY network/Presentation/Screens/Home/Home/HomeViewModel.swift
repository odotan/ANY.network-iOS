import Foundation

final class HomeViewModel: ViewModel {
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
        case .goToProfile:
            coordinator.showMyProfile()
        case .getAllContacts:
            getAll()
        case .addFavoritePressed:
            print("Add to favorite pressed")
        case .filterPressed:
            print("Filter Pressed")
        case .searchUpdated(let term):
            guard !term.isEmpty || !state.searchTerm.isEmpty else { return }
            state.searchTerm = term
        case .searchPressed:
            Task { await search(name: state.searchTerm) }
        }
    }
}

extension HomeViewModel {
    private func getAll() {
        do {
            let _ = try getAllContactsUseCase.execute()
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func search(name: String) async {
        do {
            let searched = try await searchUseCase.search(name: name)
            state.searched = searched
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
}
