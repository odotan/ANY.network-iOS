import Foundation

final class HomeViewModel: ViewModel {
    @Published private(set) var state: State
    @Published private(set) var uiState: UIState
    
    var initialContentOffset: CGPoint? = nil
    
    private let coordinator: MainCoordinatorProtocol
    private let getFavoriteContactsUseCase: GetFavoriteContactsUseCase
    private let getAllContactsUseCase: GetAllContactsUseCase
    private let searchUseCase: SearchInContactUseCase
    private let getContactsStatusUseCase: ContactsStatusUseCase
    private let getRequestAccessUseCase: GetRequestAccessUseCase
    private let priorityManager = GridPriorityManager()
    
    init(
        coordinator: MainCoordinatorProtocol,
        getFavoriteContactsUseCase: GetFavoriteContactsUseCase,
        getAllContactsUseCase: GetAllContactsUseCase,
        searchUseCase: SearchInContactUseCase,
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
            handle(.setDetent(.fraction(state.contactsStatus == .notDetermined ? 0.2 : 0.5)))
        case .requestAccess:
            Task { await requestAccess() }
        case .continueRealm:
            Task { await continueRealm() }
        case .goToProfile:
            coordinator.showMyProfile()
        case .goToDetails(let contact):
            handle(.setDrawerOpen(false))
            coordinator.showDetails(for: contact, isNew: false)
        case .goToSearch:
            handle(.setDrawerOpen(false))
            coordinator.showSearch()
        case .searchTerm(let term):
            Task { await search(term: term) }
        case .isSearching(let isSearching):
            state.isSearching = isSearching
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
//            guard detent != state.detent else { return }

            state.detent = detent
            state.isSearching = false
//            Task {
//                initialContentOffset = nil
//                handle(.setCenterPosition(.zero))
//                await prepareFavoriteGrid()
//                try? await Task.sleep(nanoseconds: 1000)
//            }
        case .setContentIdentifier:
            uiState.contentIdentifier = UUID()
        case .setCenterPosition(let point):
            if uiState.gridCenterPosition == .zero {
                uiState.gridCenterPosition = point
                handle(.recenter(false))
            } else {
                uiState.gridCenterPosition = point
            }
        case .setDrawerOpen(let isOpen):
            uiState.drawerIsOpen = isOpen
        case .addContact:
            print("Add it with searched term:", state.searchedTerm)
            handle(.setDrawerOpen(false))
            var contact = Contact(id: "")
            if state.searchedTerm.isEmail {
                contact.emailAddresses.append(LabeledValue(id: "", label: "home", value: state.searchedTerm))
            } else if state.searchedTerm.isPhoneNumber {
                contact.phoneNumbers.append(LabeledValue(id: "", label: "home", value: state.searchedTerm))
            } else {
                contact.givenName = state.searchedTerm
            }

            coordinator.showDetails(for: contact, isNew: true)
        }
    }
}

extension HomeViewModel {
    private func getStatus() async {
        do {
            state.contactsStatus = try await getContactsStatusUseCase.getStatus()
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
        handle(.setDrawerOpen(true))
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
            initialContentOffset = nil
            handle(.setCenterPosition(.zero))
            await prepareFavoriteGrid()
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func search(term: String) async {
        defer {
            state.searchedTerm = term
        }

        do {
            if !term.isEmpty {
                state.searchResults = try await searchUseCase.execute(term: term)
            } else {
                await getAll()
            }
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
    
    private func recenter(userInitiated: Bool) {
        var location: CGPoint = .zero
        
        location.x = uiState.gridContentSize.width / 2 - uiState.gridContainerSize.width / 2 - 40
        location.y = uiState.gridContentSize.height / 2 - uiState.gridContainerSize.height / 2 + 80 // keep the center over the sheet
        
        handle(.setGridContentOffset(location))
    }
}


// MARK: -- Favorite Grid
extension HomeViewModel {
    private func prepareFavoriteGrid() async {
        if let favorites = state.favorites {
            generateGrid(favorites: favorites)
        } else {
            emptyGrid()
        }

        handle(.setContentIdentifier)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.handle(.recenter(false))
        }
    }
    
    private func emptyGrid() {
        defer {
            handle(.setContentIdentifier)
            handle(.recenter(false))
        }
        
        state.gridItems = HexCell.all
    }
    
    private func generateGrid(favorites: [Contact]) {
        var array = [HexCell]()
        var count = 1
        let circles = 10
        for idx in 1..<circles {
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
