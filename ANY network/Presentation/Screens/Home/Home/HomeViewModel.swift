import Foundation

final class HomeViewModel: ViewModel {
    @Published private(set) var state: State
    @Published private(set) var uiState: UIState
    
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
        guard let favorites = state.favorites else {
            emptyGrid()
            return
        }

        switch state.detent {
        case .top:
            inlineGrid(favorites: favorites)
        case .middle:
            middleGrid(favorites: favorites)
        case .bottom:
            bottomGrid(favorites: favorites)
        default:
            emptyGrid()
        }
    }
    
    private func emptyGrid() {
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

    private func inlineGrid(favorites: [Contact]) {
        let lineCount = favorites.count < 5 ? 5 : (favorites.count % 2 == 0 ? favorites.count + 1 : favorites.count)
        var array = [HexCell]()
        var lastPriority: Int = lineCount % 2 == 0 ? lineCount / 2 + 1 : lineCount / 2
        var priorityArray = [Int]()
        
        for idx in 0..<lineCount {
            let odd = idx % 2 == 1
            let priority = lastPriority - (odd ? -idx : idx)
            lastPriority = priority
            priorityArray.append(priority)
        }

        for idx in 0..<lineCount {
            let top = HexCell(
                offsetCoordinate: .init(row: 0, col: idx),
                color: .appRaisinBlack
            )
            let priority = priorityArray.firstIndex(where: { $0 == idx })
            let center = HexCell(
                offsetCoordinate: .init(row: 1, col: idx),
                color: .appRaisinBlack,
                priority: priority
            )
            let bottom = HexCell(
                offsetCoordinate: .init(row: 2, col: idx),
                color: .appRaisinBlack
            )
            array.append(contentsOf: [top, center, bottom])
        }
        let top = HexCell(
            offsetCoordinate: .init(row: 0, col: lineCount),
            color: .appRaisinBlack
        )
        let bottom = HexCell(
            offsetCoordinate: .init(row: 2, col: lineCount),
            color: .appRaisinBlack
        )
        array.append(contentsOf: [top, bottom])
        state.gridItems = array
    }
    
    private func middleGrid(favorites: [Contact]) {
//        var array = [HexCell]()
//        let count = favorites.count
//
//        var priorityArray = [OffsetCoordinate]()
//        var lastPriority = OffsetCoordinate(row: 0, col: 0)
//        
//        for idx in 1..<count {
//            let lastRow = lastPriority.row
//            let lastCol = lastPriority.col
//
//            var priority = OffsetCoordinate(
//                row: <#T##Int#>,
//                col: <#T##Int#>
//            )
//        }
    }
    
    private func bottomGrid(favorites: [Contact]) {
        var array = [HexCell]()
        for idx in 0..<36 {
            let coords = position(for: idx)
            print("index:\(idx) coords:\(coords)")
            let cell = HexCell(offsetCoordinate: .init(row: coords.row, col: coords.col), priority: idx)
            array.append(cell)
        }
        state.gridItems = array
    }
    
    func position(for index: Int) -> (row: Int, col: Int) {
        if index == 0 {
            return (0, 0)
        }
        
        var layer = 1
        var count = 1
        
        while count + 6 * layer <= index {
            count += 6 * layer
            layer += 1
        }
        
        let positionInLayer = index - count
        let sideLength = layer
        let side = positionInLayer / sideLength
        let offset = positionInLayer % sideLength
        
        print("index:\(index); side:\(side); layer:\(layer); positionInLayer:\(positionInLayer); sideLenght:\(sideLength); offset:\(offset)")

        switch side {
        case 0: // 1
            return (row: offset, col: layer - offset/* + (offset % 3 != 0 ? 1 : 0)*/)
        case 1: // 2
            return (row: layer, col: -offset + (/*layer % 2 == 0*/layer > 1 ? 1 : 0))
        case 2: // 3
            return (row: layer - offset, col: -layer - offset + (layer > 1 ? 1 : 0))
        case 3: // 4
            return (row: -offset, col: -layer + offset)
        case 4: // 5
            return (row: -layer, col: offset - (layer > 1 ? 1 : 0))
        case 5: // 6
            return (row: -layer + offset, col: layer + offset - (layer > 1 ? 1 : 0))
        default:
            return (0, 0)
        }
    }

}

//switch side {
//case 0: // 1
//    return (row: offset, col: layer - offset)
//case 1: // 2
//    return (row: layer, col: -offset + (layer % 2 == 0 ? 1 : 0))
//case 2: // 3
//    return (row: layer - offset, col: -layer - offset + (layer % 2 == 0 ? 1 : 0))
//case 3: // 4
//    return (row: -offset, col: -layer + offset)
//case 4: // 5
//    return (row: -layer, col: offset - (layer % 2 == 0 ? 1 : 0))
//case 5: // 6
//    return (row: -layer + offset, col: layer + offset - (layer % 2 == 0 ? 1 : 0))
//default:
//    return (0, 0)
//}
