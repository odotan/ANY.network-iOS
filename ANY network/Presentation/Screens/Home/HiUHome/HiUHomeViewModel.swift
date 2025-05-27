import Foundation

final class HiUHomeViewModel: ViewModel {
    @Published private(set) var state: State
    @Published var gridModel: HiUScrollableHexGridModel = .init()

    private let coordinator: MainCoordinatorProtocol
    private let priorityManager = GridPriorityManager()
    private let gridUtilities: GridUtilities = .init(items: [HexCell]())
    
    private var timer: Timer?
    
    init(coordinator: MainCoordinatorProtocol) {
        self.state = State()
        self.coordinator = coordinator
    }
    
    func updateCellState(at coordinate: OffsetCoordinate, with model: HexFlowerModel) {
        state.cellQueue[coordinate] = model
        gridModel.refresh()
    }
    
    func handle(_ event: Event) {
        switch event {
        case .doubleTap(let cell):
            if state.selectedCell != nil {
                handle(.moveBack)
            } else {
                handle(.details(cell))
            }
        case .details(let cell):
            guard state.selectedCell == nil else { return }

            gridModel.zoom(to: 8)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                self.gridModel.center(on: cell.offsetCoordinate)
            })
            
            state.selectedCell = cell
            gridModel.refresh()
        case .moveBack:
            gridModel.zoom(to: 1)
            state.selectedCell = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                self.handle(.recenter)
            })
            gridModel.scrollEnabled = true
            gridModel.refresh()
        case .recenter:
            gridModel.recenter(paddingBottom: 100)
        case .startTimer:
            timer = Timer.scheduledTimer(
                withTimeInterval: 1,
                repeats: true,
                block: { [weak self] _ in
                    guard let self else { return }
                    Task { @MainActor in
                        self.gridModel.refresh()
                    }
            })
        case .stateUpdated(let hexState, let cell):
            print("ViewModel: State update requested for \(cell.offsetCoordinate) to state: \(hexState)")
            if let model = state.cellQueue[cell.offsetCoordinate] {
                var new = model
                new.state = hexState
                state.cellQueue[cell.offsetCoordinate] = new
            } else {
                let model = HexFlowerModel(state: hexState)
                state.cellQueue[cell.offsetCoordinate] = model
                state.cellQueueOrder.append(cell.offsetCoordinate) // Add to order tracking
            }
            
            let allReady = self.state.cellQueue.filter { $0.value.state == .selected }
            let animating = self.state.cellQueue.filter { $0.value.state == .animationStarted }
            
            print("ViewModel: Found \(allReady.count) cells in selected state and \(animating.count) cells animating")
            
            // Use the first element from our ordered list that is in ready state
            if let next = state.cellQueueOrder.first(where: { allReady.keys.contains($0) }), animating.isEmpty {
                guard var model = self.state.cellQueue[next] else { return }
                print("ViewModel: Transitioning cell at \(next) from selected to animationStarted")
                model.state = .animationStarted
                model.startedAt = Date.now
                state.cellQueue[next] = model
                print("ViewModel: State updated to animationStarted for cell at: \(next)")
                gridModel.refresh()
            }
            
            if state.cellQueue.contains(where: { $0.value.state == .timerStarted }) && timer == nil {
                handle(.startTimer)
            }
        }
    }
}
