import Foundation

final class HomeViewModel: ViewModel {
    @Published private(set) var state: State
    @Published private(set) var uiState: UIState
    
    var initialContentOffset: CGPoint? = nil
    
    private let coordinator: MainCoordinatorProtocol
    private let getFavoriteContactsUseCase: GetFavoriteContactsUseCase
    private let getAllContactsUseCase: GetAllContactsUseCase
    private let searchUseCase: SearchNameUseCase
    private let getContactsStatusUseCase: ContactsStatusUseCase
    private let getRequestAccessUseCase: GetRequestAccessUseCase
    private let priorityManager = GridPriorityManager()
    
    init(
        coordinator: MainCoordinatorProtocol,
        getFavoriteContactsUseCase: GetFavoriteContactsUseCase,
        getAllContactsUseCase: GetAllContactsUseCase,
        searchUseCase: SearchNameUseCase,
        getContactsStatusUseCase: ContactsStatusUseCase,
        getRequestAccessUseCase: GetRequestAccessUseCase
    ) {
        self.state = State()
        self.uiState = UIState()
        self.coordinator = coordinator
        self.getFavoriteContactsUseCase = getFavoriteContactsUseCase
        self.getAllContactsUseCase = getAllContactsUseCase
        self.searchUseCase = searchUseCase
        self.getContactsStatusUseCase = getContactsStatusUseCase
        self.getRequestAccessUseCase = getRequestAccessUseCase
        
        handle(.checkContactsStatus)
    }
    
    func handle(_ event: Event) {
        switch event {
        case .checkContactsStatus:
            Task { await getStatus() }
            handle(.setDetent(.top))
            handle(.setDrawerContentHeight(180))
        case .requestAccess:
            Task { await requestAccess() }
        case .continueRealm:
            Task { await continueRealm() }
        case .goToProfile:
            coordinator.showMyProfile()
        case .goToDetails(let contact):
            coordinator.showDetails(for: contact)
        case .goToSearch:
            coordinator.showSearch()
        case .recenter(let userInitiated):
            recenter(userInitiated: userInitiated)
        case .headerSize(let size):
            uiState.headerSize = size
        case .getAllContacts:
            Task { await getAll() }
        case .getFavoriteContacts:
            Task { await getFavorite() }
            handle(.recenter(false))
        case .addFavoritePressed:
            print("Add to favorite pressed")
        case .filterPressed:
            print("Filter Pressed")
        case .setSheetSize(let size):
            uiState.sheetSize = size
        case .setGridContainerSize(let size):
            uiState.gridContainerSize = size
//            handle(.recenter(false))
//            if size.height > 350 {
//                handle(.setDetent(.bottom))
//            } else if size.height < 340 {
//                handle(.setDetent(.top))
//            }
        case .setGridZoomScale(let scale):
            uiState.gridZoomScale = scale
        case .setGridContentOffset(let offset):
            uiState.gridContentOffset = offset
        case .setGridContentSize(let size):
            uiState.gridContentSize = size
        case .setDetent(let detent):
            guard detent != state.detent else { return }
            
            state.detent = detent
            Task {
                initialContentOffset = nil
                handle(.setCenterPosition(.zero))
                await prepareFavoriteGrid()
                try? await Task.sleep(nanoseconds: 1000)
            }
        case .setContentIdentifier:
            uiState.contentIdentifier = UUID()
        case .setCenterPosition(let point):
            if uiState.gridCenterPosition == .zero {
                uiState.gridCenterPosition = point
                handle(.recenter(false))
            } else {
                uiState.gridCenterPosition = point
            }
        case .setDrawerContentHeight(let height):
            uiState.drawerContentHeight = height
            
            if height > 350 {
                handle(.setDetent(.bottom))
            } else if height < 340 {
                handle(.setDetent(.top))
            }
        }
    }
}

extension HomeViewModel {
    private func getStatus() async {
        do {
            state.contactsStatus = try await getContactsStatusUseCase.getStatus()
            print(state.contactsStatus)
        } catch {
            print("Error", error.localizedDescription)
        }
    }
    
    private func continueRealm() async {
        do {
            try await getContactsStatusUseCase.update(status: .realm)
            refresh()
        } catch {
            print("Error", error.localizedDescription)
        }
    }

    private func requestAccess() async {
        do {
            try await getRequestAccessUseCase.requestAccess()
            refresh()
        } catch {
            refresh()
            print("Error", error.localizedDescription)
        }
    }
    
    private func refresh() {
        handle(.checkContactsStatus)
        handle(.getAllContacts)
        handle(.getFavoriteContacts)
    }
    
    private func getAll() async {
        do {
            state.list = try await getAllContactsUseCase.execute()
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func getFavorite() async {
        do {
            state.favorites = try await getFavoriteContactsUseCase.execute()
            handle(.setDetent(.top))
            initialContentOffset = nil
            handle(.setCenterPosition(.zero))
            await prepareFavoriteGrid()
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func recenter(userInitiated: Bool) {
        guard uiState.gridCenterPosition != .zero else { return }
        if initialContentOffset == nil {
            initialContentOffset = uiState.gridContentOffset
        }

        // It depends if the user has pressed the button or have moved the drawer
        let cOffset = userInitiated ? uiState.gridContentOffset : initialContentOffset!
        var location = uiState.gridCenterPosition
        
        
        if uiState.gridContainerSize.height >= uiState.gridContentSize.height {
            location.y = 0
        } else {
            location.y -= uiState.gridContainerSize.height / 2 //- uiState.gridContentOffset.y
            location.y += cOffset.y
            location.y -= uiState.headerSize.height
        }
        location.y = location.y < 0 ? uiState.gridContentOffset.y : location.y
        
        if uiState.gridContainerSize.width >= uiState.gridContentSize.width {
            location.x = 0
        } else {
            location.x -= uiState.gridContainerSize.width / 2// - uiState.gridContentOffset.x
            location.x += uiState.gridContentOffset.x
        }
        location.x = location.x < 0 ? uiState.gridContentOffset.x : location.x

        handle(.setGridContentOffset(location))
    }
    
//    private func recenter(userInitiated: Bool) {
//        if initialContentOffset == nil {
//            initialContentOffset = uiState.gridContentOffset
//        }
//
//        // It depends if the user has pressed the button or have moved the drawer
//        var cOffset = userInitiated ? uiState.gridContentOffset : initialContentOffset
//        var location = uiState.gridCenterPosition
//        if uiState.gridContainerSize.height >= uiState.gridContentSize.height {
//            location.y = uiState.gridContentOffset.y
//        } else {
//            location.y -= uiState.gridContainerSize.height / 2 //- uiState.gridContentOffset.y
//            location.y += cOffset!.y
//            location.y -= uiState.headerSize.height
//        }
//        location.y = location.y < 0 ? uiState.gridContentOffset.y : location.y
//        
//        print(location.y, uiState.gridCenterPosition.y, cOffset!.y, uiState.gridContainerSize)
//        
//        if uiState.gridContainerSize.width >= uiState.gridContentSize.width {
//            location.x = uiState.gridContentOffset.x
//        } else {
//            location.x -= uiState.gridContainerSize.width / 2// - uiState.gridContentOffset.x
//            location.x += uiState.gridContentOffset.x
//        }
//        location.x = location.x < 0 ? uiState.gridContentOffset.x : location.x
//
//        handle(.setGridContentOffset(location))
//    }
}


// MARK: -- Favorite Grid
extension HomeViewModel {
    private func prepareFavoriteGrid() async {
        defer {
            handle(.setContentIdentifier)
            handle(.recenter(false))
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
            handle(.recenter(false))
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
        let lineCount = favorites.count < 7 ? 7 : (favorites.count % 2 == 0 ? favorites.count + 1 : favorites.count)
        let numberOfElements = lineCount * 3
        var array = [HexCell]()
        
        var lastPriority: Int?
        for idx in 0..<numberOfElements {
            let coords = priorityManager.positionTop(for: idx)
            let priority: Int? = coords.row == 0 ? (lastPriority == nil ? 0 : (lastPriority! + 1)) : nil
            let cell = HexCell(offsetCoordinate: coords, color: .appRaisinBlack, priority: priority)
            array.append(cell)

            if let priority = priority {
                lastPriority = priority
            }
        }

        state.gridItems = array
    }
    
    private func middleGrid(favorites: [Contact]) {
        let count = favorites.count <= 19 ? 19 : favorites.count
        var array = [HexCell]()
        for idx in 0..<count {
            let coords = priorityManager.positionMiddle(for: idx)
//            print("index:\(idx) coords:\(coords)")
            let cell = HexCell(offsetCoordinate: coords, color: .appRaisinBlack, priority: idx)
            array.append(cell)
        }
        state.gridItems = array
    }
    
    private func bottomGrid(favorites: [Contact]) {
        var array = [HexCell]()
        var count = 1
        for idx in 1..<5 {
            count += idx * 6
        }

        for idx in 0..<count {
            let coords = priorityManager.positionBottom(for: idx)
//            print("index:\(idx) coords:\(coords)")
            let cell = HexCell(offsetCoordinate: coords, color: .appRaisinBlack, priority: idx)
            array.append(cell)
        }
        state.gridItems = array
    }
}
