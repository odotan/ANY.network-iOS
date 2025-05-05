import Foundation

final class ConnectNetworkConfirmationViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    
    init(networkItem: NetworkItem, coordinator: MainCoordinatorProtocol) {
        self.state = State(networkItem: networkItem)
        self.coordinator = coordinator
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.pop()
        case .setIsPublic(let isPublic):
            state.isPublic = isPublic
        case .setIsSearchable(let isSearchable):
            state.isSearchable = isSearchable
        case .connect:
            // Do the magic
            coordinator.pop(2)
        }
    }
}
