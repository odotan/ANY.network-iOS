import Foundation

final class RequestNetworkViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    
    @Published var gridModel: ScrollableHexGridModel = .init()
    
    init(contact: Contact, coordinator: MainCoordinatorProtocol) {
        self.state = State(contact: contact)
        self.coordinator = coordinator
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.pop()
        case .recenter:
            gridModel.recenter(paddingBottom: 100)
        case .select(let cell):
            guard state.selectedCell == nil else { return }

            gridModel.zoom(to: 8)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                self.gridModel.center(on: cell.offsetCoordinate)
            })
            
            state.selectedCell = cell
            gridModel.scrollEnabled = false
            gridModel.refresh()
        case .moveBack:
            gridModel.zoom(to: 1)
            state.selectedCell = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                self.handle(.recenter)
            })
            gridModel.scrollEnabled = true
            gridModel.refresh()
        case .pointsUpdated(let points):
            state.points = points
        }
    }
}
