import Foundation

final class HomeViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let getFavoriteContactsUseCase: GetFavoriteContactsUseCase
    private let getAllContactsUseCase: GetAllContactsUseCase
    private let searchUseCase: SearchNameUseCase
    
    init(
        coordinator: MainCoordinatorProtocol,
        getFavoriteContactsUseCase: GetFavoriteContactsUseCase,
        getAllContactsUseCase: GetAllContactsUseCase,
        searchUseCase: SearchNameUseCase
    ) {
        self.state = State()
        self.coordinator = coordinator
        self.getFavoriteContactsUseCase = getFavoriteContactsUseCase
        self.getAllContactsUseCase = getAllContactsUseCase
        self.searchUseCase = searchUseCase
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goToProfile:
            coordinator.showMyProfile()
            handle(.sheetPresentationUpdated(to: false))
        case .goToDetails(let contact):
            coordinator.showDetails(for: contact)
            handle(.sheetPresentationUpdated(to: false))
        case .goToSearch:
            coordinator.showSearch()
            handle(.sheetPresentationUpdated(to: false))
        case .getAllContacts:
            Task { await getAll() }
        case .getFavoriteContacts:
            Task { await getFavorite() }
        case .addFavoritePressed:
            print("Add to favorite pressed")
        case .filterPressed:
            print("Filter Pressed")
//        case .searchUpdated(let term):
//            state.searchTerm = term
//            Task { await search(name: state.searchTerm) }
//        case .searchPressed:
//            Task { await search(name: state.searchTerm) }
        case .sheetPresentationUpdated(let value):
            state.isSheetPresented = value
        }
    }
}

extension HomeViewModel {
    private func getAll() async {
        do {
            state.list = try await getAllContactsUseCase.execute()
            print("All", Thread.current, Task.currentPriority)
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func getFavorite() async {
        do {
            let favorite = try await getFavoriteContactsUseCase.execute()
            print("FAV", Thread.current, Task.currentPriority)
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
}
