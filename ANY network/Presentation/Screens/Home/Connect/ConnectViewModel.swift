import Foundation

final class ConnectViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    
    @Published var gridModel: ScrollableHexGridModel = .init()

    private let priorityManager = GridPriorityManager()
    private let gridUtilities: GridUtilities = .init(items: HexCell.all)
    
    init(contact: Contact, coordinator: MainCoordinatorProtocol) {
        self.state = State(contact: contact)
        self.coordinator = coordinator
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.pop()
        case .recenter:
            gridModel.recenter()
        case .networkSelected(let networkItem):
            coordinator.showConnectSignUp(networkItem: networkItem, contact: state.contact)
        }
    }
    
    func checkIfAvailable(network: NetworkItem) -> Bool {
        return state.availableNetworks.contains(network)
    }
}
