import Foundation
import UIKit

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
    private let getIsMeContactUseCase: GetIsMeContactUseCase
    private let checkIfRealmContainsContacts: CheckIfRealmContainsContacts
    private let mergeRealmContactsUseCase: MergeRealmContactsUseCase
    private let priorityManager = GridPriorityManager()
    private let gridUtilities: GridUtilities

    // MARK: Interactions
    private let fetchInteractionsUseCase: FetchInteractionsUseCase
    private let interactWithContactUseCase: InteractWithContactUseCase
    private let deleteInteractionUseCase: DeleteInteractionUseCase

    init(
        coordinator: MainCoordinatorProtocol,
        getFavoriteContactsUseCase: GetFavoriteContactsUseCase,
        getAllContactsUseCase: GetAllContactsUseCase,
        searchUseCase: SearchInContactUseCase,
        getContactsStatusUseCase: ContactsStatusUseCase,
        getRequestAccessUseCase: GetRequestAccessUseCase,
        checkIfRealmContainsContacts: CheckIfRealmContainsContacts,
        mergeRealmContactsUseCase: MergeRealmContactsUseCase,
        fetchInteractionsUseCase: FetchInteractionsUseCase,
        interactWithContactUseCase: InteractWithContactUseCase,
        deleteInteractionUseCase: DeleteInteractionUseCase,
        getIsMeContactUseCase: GetIsMeContactUseCase
    ) {
        self.state = State()
        self.uiState = UIState()
        self.coordinator = coordinator
        self.getFavoriteContactsUseCase = getFavoriteContactsUseCase
        self.getAllContactsUseCase = getAllContactsUseCase
        self.searchUseCase = searchUseCase
        self.getContactsStatusUseCase = getContactsStatusUseCase
        self.getRequestAccessUseCase = getRequestAccessUseCase
        self.fetchInteractionsUseCase = fetchInteractionsUseCase
        self.checkIfRealmContainsContacts = checkIfRealmContainsContacts
        self.mergeRealmContactsUseCase = mergeRealmContactsUseCase
        self.interactWithContactUseCase = interactWithContactUseCase
        self.deleteInteractionUseCase = deleteInteractionUseCase
        self.getIsMeContactUseCase = getIsMeContactUseCase
        self.gridUtilities = .init(items: [HexCell]())
        
        handle(.checkContactsStatus)
        handle(.fetchInteractions)
    }
    
    func handle(_ event: Event) {
//        print(event)
        switch event {
        case .checkContactsStatus:
            Task { await getStatus() }
            handle(.setDetent(.fraction(state.contactsStatus == .notDetermined ? 0.2 : 0.5)))
        case .requestAccess:
            Task { await requestAccess() }
        case .continueRealm:
            Task { await continueRealm() }
        case .goToProfile:
            handle(.setDrawerOpen(false))
            coordinator.showMyProfile {
                self.handle(.setDrawerOpen(true))
                self.refresh()
            }
        case .goToDetails(let contact, let point):
            handle(.setDrawerOpen(false))
            coordinator.showDetails(
                for: contact,
                isNew: false,
                anchor: point,
                onContactChangeEvent: handleContactEvent
            )
        case .goToSearch:
            handle(.setDrawerOpen(false))
            coordinator.showSearch(onContactChangeEvent: handleContactEvent)
        case .searchTerm(let term):
            Task { await search(term: term) }
        case .isSearching(let isSearching):
            state.isSearching = isSearching
        case .recenter(let userInitiated):
            guard state.contactsStatus != .notDetermined else { return }

            if uiState.gridContentOffset.integerPartEqualTo(gridCenter) { // Ignore floating point, since slight deviation doesnt matter
                resetZoom()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.recenter(userInitiated: userInitiated)
                }
            } else {
                recenter(userInitiated: userInitiated)
            }

        case .headerSize(let size):
            uiState.headerSize = size
        case .getAllContacts:
            Task { await getAll() }
        case .getFavoriteContacts:
            Task {
                await getFavorite()
                await getIsMe()
            }
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

            coordinator.showDetails(
                for: contact,
                isNew: false,
                anchor: nil,
                onContactChangeEvent: handleContactEvent
            )
        case .fetchInteractions:
            Task { await fetchInteractions() }
        case .interact(let interaction, let actionType):
            Task { await interact(interaction: interaction, actionType: actionType) }
        case .perform(let interaction):
            perform(interaction: interaction)
        case .setIsEditing(let isEditing):
            uiState.isEditing = isEditing
            handle(.setContentIdentifier)
        case .deleteInteraction(let id):
            Task { await deleteInteraction(id: id) }
        case .moveInteraction(let id, let priority):
            moveInteraction(id: id, to: priority)
        case .isDraggingAHexagon(let isDragging):
            uiState.isDraggingAHexagon = isDragging
        case .didDropDraggedHexagon(let didDrop):
            uiState.didDropDraggedHexagon = didDrop
            handle(.isDraggingAHexagon(false))
            handle(.targetHexagon(nil))
        case .targetHexagon(let hex):
            setTargetedHex(targetedHex: hex)
        case .toggleFullscreen:
            coordinator.toggleFullscreen()
            uiState.isInFullscreen.toggle()
        case .setCellToGet(let prio):
            state.cellToGet = prio
        case .goToOffset(let offset, let screenSize):
            let translated = calculateOffsetNeededToReach(offset, screenSize: screenSize)
            handle(.setGridContentOffset(translated))
        case .askForRealmMerge(let show):
            state.shouldAskRealmMerge = show
        case .mergeRealmContacts:
            Task { await mergeRealmContacts() }
        case .swapHexagons(let target, let swapper):
            swapHexagons(swap: target, with: swapper)
        case .showSettingsAlert(let show):
            state.showSettingsAlert = show
        case .openSettingsApp:
            openSettingsApp()
        }
    }
}

extension HomeViewModel {
    private func getStatus() async {
        do {
            let currentStatus = try await getContactsStatusUseCase.getStatus()
            state.contactsStatus = currentStatus
            
            if case .realm = currentStatus {
                // SHOW SETTINGS ALERT
            } else if case .native = currentStatus {
                guard try await checkIfRealmContainsContacts.execute() else {
                    return
                }
                handle(.askForRealmMerge(true))
            }
        } catch {
            print("Error", error.localizedDescription)
        }
    }
    
    private func getIsMe() async {
        do {
            let isMeContact = try await getIsMeContactUseCase.execute()
            state.isMe = isMeContact
        } catch {
            print("Error fetching IS ME:", error.localizedDescription)
        }
    }
    
    private func mergeRealmContacts() async {
        do {
            try await mergeRealmContactsUseCase.execute()
            handle(.getAllContacts)
        } catch {
            print("error while merging contacts:", error.localizedDescription)
        }
    }
    
    private func openSettingsApp() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(url)
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
        handle(.fetchInteractions)
        Task { await getIsMe() } 
    }
    
    private func getAll() async {
        do {
            state.list = try await getAllContactsUseCase.execute()
            print(state.list?.filter { $0.isMe })
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
        handle(.setGridContentOffset(gridCenter))
    }

    private func resetZoom() {
        handle(.setGridZoomScale(1))
    }

    private func calculateOffsetNeededToReach(_ point: CGPoint, screenSize: CGRect) -> CGPoint {
        let size = screenSize.size
        let location = CGPoint(
            x: -(size.width / 2 - point.x),
            y: -(size.height / 2 - point.y) + 80
        )
        return uiState.gridContentOffset.applying(.init(translationX: location.x, y: location.y))
    }

    private var gridCenter: CGPoint {
        .init(
            x: uiState.gridContentSize.width / 2 - uiState.gridContainerSize.width / 2 - ((<->40) * uiState.gridZoomScale),
            y: uiState.gridContentSize.height / 2 - uiState.gridContainerSize.height / 2 + 80 // keep the center over the sheet
        )
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
        let circles = 19
        for idx in 1..<circles {
            count += idx * 6
        }

        for idx in 0..<count {
            let coords = priorityManager.positionBottom(for: idx)
//            print("index:\(idx) coords:\(coords)")
            let cell = HexCell(offsetCoordinate: coords, color: .appRaisinBlack, priority: idx == 0 ? -1 : idx - 1)
            array.append(cell)
        }
        let coloredGrid = generateGridColors(grid: array)
        state.gridItems = coloredGrid
        gridUtilities.recalculateGrid(with: state.gridItems)
    }
    
    private func generateGridColors(grid: [HexCell]) -> [HexCell] {
        var coloredGrid = [HexCell]()
        coloredGrid.reserveCapacity(grid.count)
        
        for cell in grid {
            let offset = (row: -4, col: -2) // The offset we need to put 4, 2 from `HexCell.all` in the center
            if let defaultBackgroundCell = HexCell.all.first(where: {
                $0.offsetCoordinate.row == (cell.offsetCoordinate.row - offset.row) &&
                $0.offsetCoordinate.col == (cell.offsetCoordinate.col - offset.col + (cell.offsetCoordinate.row % 2 != 0 ? 1 : 0))
            }) {
                var coloredHex = cell
                coloredHex.color = defaultBackgroundCell.color
                coloredGrid.append(coloredHex)
            } else {
                var coloredHex = cell
                coloredHex.color = .init(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    opacity: .random(in: 0.02...0.035)
                )
                coloredGrid.append(coloredHex)
            }
        }
        
        return coloredGrid
    }
    
    private func setTargetedHex(targetedHex: HexCell?) {
        for item in state.gridItems where item.isSelected {
            if let index = state.gridItems.firstIndex(of: item) {
                state.gridItems[index].isSelected = false
            }
        }
        
        guard let targetedHex, let index = state.gridItems.firstIndex(of: targetedHex) else {
            return
        }
        
        state.gridItems[index].isSelected = true
    }
    
    private func getHexagonsAdjacent(to cell: HexCell) -> [HexCell] {
        let adjacent = gridUtilities.getOffsetCoordinateOfAdjacentCells(to: cell)
        return state.gridItems.filter { item in adjacent.contains { $0 == item.offsetCoordinate }}
    }
}

// MARK: - Interactions
extension HomeViewModel {
    func selectInteractionPriority(for cell: HexCell) -> Int {
        guard let priority = cell.priority else { return 0 }
        let prio: Int
        let interactions = state.interactions
        let adjacent = getHexagonsAdjacent(to: cell).filter { $0.priority != -1 }
        
        guard !adjacent.isEmpty else { return 0 }
        let free = adjacent.filter { hex in !interactions.contains { $0.priority == hex.priority } }
        
        if free.isEmpty {
            prio = selectInteractionPriority(for: adjacent.randomElement()!)
        } else {
            guard let priority = free.randomElement()!.priority else { return 0 }
            prio = priority
        }
        
        return prio
    }
    
    private func interact(interaction: ContactInteraction, actionType: InteractionActionType) async {
        do {
            if let index = state.interactions.firstIndex(where: { $0.interactionId == interaction.interactionId }) {
                let prio = state.interactions[index].priority
                var new = interaction
                new.priority = prio
                try await interactWithContactUseCase.extecute(interaction: new, type: actionType)
            } else {
                let newestInteraction = state.interactions.max { $0.date < $1.date }
                let cellOfNewestInteraction = state.gridItems.first(where: { $0.priority == newestInteraction?.priority })
                var new = interaction
                if let cellOfNewestInteraction {
                    new.priority = selectInteractionPriority(for: cellOfNewestInteraction)
                } else {
                    new.priority = 0
                }
                try await interactWithContactUseCase.extecute(interaction: new, type: actionType)
            }
            handle(.fetchInteractions)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func fetchInteractions() async {
        do {
            let old = state.interactions
            let new = try await fetchInteractionsUseCase.execute()
            state.interactions = new
            
            // Check if a new interaction was added, and set its priority as the cell to get
            let difference = new.filter { !old.contains($0) }
            guard difference.count == 1, let first = difference.first else { return }
            handle(.setCellToGet(first.priority))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteInteraction(id: String) async {
        do {
            try await deleteInteractionUseCase.execute(id: id)
            if let index = state.interactions.firstIndex(where: { $0.id == id }) {
                state.interactions.remove(at: index)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getInteractionValues(for interaction: ContactInteraction) -> ContactInteractionValueCreator.Interaction? {
        guard let contacts = state.list, !contacts.isEmpty else { return nil }
        do {
            let creator = ContactInteractionValueCreator()
            return try creator.getInteraction(for: interaction, from: state.list ?? [])
        } catch {
#warning("Handle error")
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func moveInteraction(id: String?, to cellPriority: Int?) {
        guard let id, let cellPriority, cellPriority > 0 else { return }
        guard let selectedInteractionIndex = state.interactions.firstIndex(where: { $0.id == id }) else { return }
        
        if let indexOfInteractionWithThisPriority = state.interactions.firstIndex(where: { $0.priority == cellPriority }) {
            swapInteractionPriorities(selectedIndex: selectedInteractionIndex, indexToSwapWith: indexOfInteractionWithThisPriority)
        } else {
            print("Changed interaction: \(id), previous priority \(state.interactions[selectedInteractionIndex].priority), current \(cellPriority)")
            state.interactions[selectedInteractionIndex].priority = cellPriority
            handle(.interact(state.interactions[selectedInteractionIndex], .move))
        }
    }
    
    private func swapInteractionPriorities(selectedIndex: Int, indexToSwapWith: Int) {
        guard selectedIndex != indexToSwapWith else { print("indecies were the same, no change happened"); return }
        let selectedInteractionPriority = state.interactions[selectedIndex].priority
        let priorityToSwapWith = state.interactions[indexToSwapWith].priority
        
        state.interactions[selectedIndex].priority = priorityToSwapWith
        state.interactions[indexToSwapWith].priority = selectedInteractionPriority
        print("Swapped interactions: \(state.interactions[selectedIndex].id) and \(state.interactions[indexToSwapWith].id), previous priority of the swapper was \(selectedInteractionPriority), current \(state.interactions[selectedIndex].priority), previous priority of the swappee was \(priorityToSwapWith), current \(state.interactions[indexToSwapWith].priority)")
        
        handle(.interact(state.interactions[selectedIndex], .move))
        handle(.interact(state.interactions[indexToSwapWith], .move))
    }
    
    private func swapHexagons(swap target: Int?, with swapper: Int?) {
        guard let target, let swapper else { return }
        // Check if any of the hexagons have interactions.
        let interactionTarget = state.interactions.first { $0.priority == target }
        let interactionSwapper = state.interactions.first { $0.priority == swapper }
        
        if interactionTarget != nil || interactionSwapper != nil {
            moveInteraction(id: interactionTarget?.id, to: swapper)
            moveInteraction(id: interactionSwapper?.id, to: target)
            // We call both variants, since the only way to call this func is if you move a hexagon,
            // therefore if you move a hex on top of an interaction, only one of these will not be nil
            // and the one with a nil value will just return withought doing anything.
        }
        
        let cells = state.gridItems
        guard
            let targetIndex = cells.firstIndex(where: { $0.priority == target }),
            let swapperIndex = cells.firstIndex(where: { $0.priority == swapper })
        else {
            return
        }
        
        let targetColor = cells[targetIndex].color
        let swapperColor = cells[swapperIndex].color
        
        state.gridItems[targetIndex].color = swapperColor
        state.gridItems[swapperIndex].color = targetColor
    }
}

// MARK: - ContactActions
extension HomeViewModel {
    private func perform(interaction: ContactInteraction) {
        do {
            guard let value = getInteractionValues(for: interaction)?.value else {
                #warning("Handle error")
                return
            }
            let action = try ContactActionCreator().createAction(for: value)
            try action.performAction()
            handle(.interact(interaction, .create))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func handleContactEvent(_ event: ContactChangeEvent) {
        switch event {
        case .favorite:
            handle(.setContentIdentifier)
        case .interacted:
            handle(.fetchInteractions)
        case .updated:
            handle(.getAllContacts)
        }
    }
}

enum ContactChangeEvent {
    case favorite, interacted, updated
}
