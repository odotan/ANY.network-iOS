import Foundation

final class HomeViewModel: ViewModel {
    @Published private(set) var state: State
    @Published private(set) var uiState: UIState
    
    private let coordinator: MainCoordinatorProtocol
    private let getFavoriteContactsUseCase: GetFavoriteContactsUseCase
    private let getAllContactsUseCase: GetAllContactsUseCase
    private let searchUseCase: SearchNameUseCase
    private let priorityManager = GridPriorityManager()
    
    init(
        coordinator: MainCoordinatorProtocol,
        getFavoriteContactsUseCase: GetFavoriteContactsUseCase,
        getAllContactsUseCase: GetAllContactsUseCase,
        searchUseCase: SearchNameUseCase
    ) {
        self.state = State()
        self.uiState = UIState()
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
        case .recenter:
            uiState.gridContentOffset = CGPoint(
                x: uiState.gridContentSize.width / 2 - uiState.gridContainerSize.width / 2,
                y: uiState.gridContentSize.height / 2 - uiState.gridContainerSize.height / 2
            )
        case .getAllContacts:
            Task { await getAll() }
        case .getFavoriteContacts:
            Task { await getFavorite() }
        case .addFavoritePressed:
            print("Add to favorite pressed")
        case .filterPressed:
            print("Filter Pressed")
        case .sheetPresentationUpdated(let value):
            state.isSheetPresented = value
        case .setSheetSize(let size):
            uiState.sheetSize = size
        case .setGridContainerSize(let size):
            uiState.gridContainerSize = size
        case .setGridZoomScale(let scale):
            uiState.gridZoomScale = scale
        case .setGridContentOffset(let offset):
            uiState.gridContentOffset = offset
        case .setGridContentSize(let size):
            uiState.gridContentSize = size
        case .setDetent(let detent):
            state.detent = detent
            Task { await prepareFavoriteGrid() }
        case .setContentIdentifier:
            uiState.contentIdentifier = UUID()
        }
    }
}

extension HomeViewModel {
    private func getAll() async {
        do {
            state.list = try await getAllContactsUseCase.execute()
//            print("All VM", Thread.current, Task.currentPriority)
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func getFavorite() async {
        do {
            state.favorites = try await getFavoriteContactsUseCase.execute()
            await prepareFavoriteGrid()
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
}

// MARK: -- Favorite Grid
extension HomeViewModel {
    private func prepareFavoriteGrid() async {
        defer {
            handle(.setContentIdentifier)
        }
        
        guard let favorites = state.favorites else {
            emptyGrid()
            return
        }
        
        switch state.detent {
        case .top:
            topGrid(favorites: favorites)
        case .middle:
            middleGrid(favorites: favorites)
        case .bottom:
            bottomGrid(favorites: favorites)
        default:
            emptyGrid()
        }
    }
    
    private func emptyGrid() {
        defer {
            handle(.setContentIdentifier)
        }
        
        switch state.detent {
        case .top:
            state.gridItems = HexCell.inline
        case .middle:
            state.gridItems = HexCell.middle
        case .bottom:
            state.gridItems = HexCell.all
        default:
            state.gridItems = []
        }
    }
    
    private func topGrid(favorites: [Contact]) {
        let lineCount = favorites.count < 5 ? 5 : (favorites.count % 2 == 0 ? favorites.count + 1 : favorites.count)
        let numberOfElements = lineCount * 3
        var array = [HexCell]()
        
        var lastPriority = 0
        for idx in 0..<numberOfElements {
            let coords = priorityManager.positionTop(for: idx)
            let priority: Int? = coords.row == 0 ? (lastPriority + 1) : nil
            let cell = HexCell(offsetCoordinate: coords, color: .appRaisinBlack, priority: priority)
            array.append(cell)

            if let priority = priority {
                lastPriority = priority
            }
        }

        state.gridItems = array
    }
    
    private func middleGrid(favorites: [Contact]) {
        var array = [HexCell]()
        for idx in 0..<100 {
            let coords = priorityManager.positionMiddle(for: idx)
//            print("index:\(idx) coords:\(coords)")
            let cell = HexCell(offsetCoordinate: coords, color: .appRaisinBlack, priority: idx)
            array.append(cell)
        }
        state.gridItems = array
    }
    
    private func bottomGrid(favorites: [Contact]) {
        var array = [HexCell]()
        for idx in 0..<200 {
            let coords = priorityManager.positionBottom(for: idx)
//            print("index:\(idx) coords:\(coords)")
            let cell = HexCell(offsetCoordinate: coords, color: .appRaisinBlack, priority: idx)
            array.append(cell)
        }
        state.gridItems = array
    }
}
