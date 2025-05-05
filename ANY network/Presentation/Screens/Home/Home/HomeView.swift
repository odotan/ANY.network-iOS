import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @Namespace var namespace
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var animationRedo: AnimationRedo
    
    @State private var hexTargetView: AnyView?
    @State private var targetedHexPos: CGPoint?
    @State private var swapperPos: CGPoint?
    
    private var detents: Set<PresentationDetent> {
        var detents: Set<PresentationDetent> = .init([.fraction(0.1)])
        for i in 11..<80 {
            let fraction = CGFloat(i) / 100
            detents.insert(.fraction(fraction))
        }
        return detents
    }

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.uiState.isInFullscreen {
                header
                    .id("header")
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            favourites
                .sheet(isPresented: drawerIsOpen) {
                    VStack {
                        if !viewModel.state.onboardingFinished {
                            onboarding
                        } else if viewModel.state.showAll {
                            if viewModel.state.isMe == nil {
                                AssignYourContactPopup {
                                    viewModel.handle(.goToProfile)
                                }
                            }

                            allContacts
                                .searchTextField(text: searchTerm, isSearching: isSearching) {
                                    viewModel.handle(.addContact)
                                }
                                .alert(
                                    "Contact permissions are not enabled",
                                    isPresented: showSettingsAlert,
                                    presenting: 1,
                                    actions: { _ in
                                        HStack {
                                            Button("Settings", action: { viewModel.handle(.openSettingsApp) })
                                            Button("OK", action: { showMergeAlert.wrappedValue = false })
                                        }
                                    },
                                    message: { _ in
                                        Text("This will be used to help you manage your contacts.")
                                    }
                                )
                        } else {
                            EmptyView()
                        }
                    }
                    .alert(
                        "You have untransfered contacts",
                        isPresented: showMergeAlert,
                        presenting: 1,
                        actions: { _ in
                            HStack {
                                Button("Merge", action: { viewModel.handle(.mergeRealmContacts) })
                                Button("Do not merge", action: { showMergeAlert.wrappedValue = false })
                            }
                        },
                        message: { _ in
                            Text("Would you like to merge the contacts you have created into your phone's contact book? Merged contacts will be deleted from local storage after the merge is complete.")
                        }
                    )
                    .padding(.top)
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .presentationBackground(.clear)
                            .background(Color.appBackground.opacity(0.1))
                            .ignoresSafeArea()
                    )
                    .pillToolbar(
                        items: [
                            .init(icon: .search, position: .middle, action: { isSearching.wrappedValue = true }),
                            .init(icon: .recenter, position: .middle, action: { viewModel.handle(.recenter(true)) })
                        ],
                        visible: !isSearching.wrappedValue && viewModel.state.onboardingFinished
                    )
                    .overlay(alignment: .top) {
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .presentationBackground(.clear)
                            .background(Color.appBackground)
                            .ignoresSafeArea()
                            .frame(height: 50)
                            .mask { LinearGradient(gradient: Gradient(colors: [.black, .black, .clear]), startPoint: .top, endPoint: .bottom) }
                    }
                    .presentationDetents(detents, selection: detent)
                    .presentationBackgroundInteraction(.enabled)
                    .presentationContentInteraction(.scrolls)
                    .interactiveDismissDisabled()
                }
                .onDisappear {
                    viewModel.handle(.setDrawerOpen(false))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.handle(.setDrawerOpen(true))
                        viewModel.handle(.recenter(true))
                    }
                }
                .onChange(of: viewModel.state.contactsStatus) { _, newValue in
                    detent.wrappedValue = viewModel.state.onboardingFinished ? .fraction(0.5) : .fraction(0.2)
                }
        }
        .task {
            viewModel.handle(.getAllContacts)
        }
        .task {
            viewModel.handle(.getFavoriteContacts)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color.appBackground)
        .onChange(of: viewModel.state.interactions) { _, _ in
            viewModel.handle(.setContentIdentifier)
            print("Interactions changed, redraw")
        }
        .onChange(of: viewModel.state.list) { _, _ in viewModel.handle(.setContentIdentifier) }
        .onReceive(NotificationCenter.default.publisher(for: .ContactFavoritesChanged).receive(on: RunLoop.main), perform: { _ in
            viewModel.handle(.getFavoriteContacts)
            viewModel.handle(.setContentIdentifier)
        })
        .onChange(of: isDragging.wrappedValue) { _, _ in viewModel.handle(.setContentIdentifier) }
        .onChange(of: targetedHex.wrappedValue) { _, _ in viewModel.handle(.setContentIdentifier) }
        .onChange(of: viewModel.uiState.isInFullscreen) { _, new in viewModel.handle(.setDrawerOpen(!new)) }
        .sensoryFeedback(.impact, trigger: isEditing.wrappedValue)
        .sensoryFeedback(.selection, trigger: isDragging.wrappedValue)
        .sensoryFeedback(.impact, trigger: didDrop.wrappedValue)
        .overlay {
            if let hexTargetView, let targetedHexPos, let swapperPos {
                HexagonSwapAnimationOverlay(swapeePos: targetedHexPos, swaperPos: swapperPos) {
                    hexTargetView
                }
            }
        }
    }
    
    @ViewBuilder
    var header: some View {
        HStack(spacing: 0) {
            Spacer()
            
            Menu {
                Button(action: { animationRedo.redoAnimation = true } ) {
                    Text("Show animation again")
                }
                
                Button(action: {
                    for interaction in viewModel.state.interactions {
                        viewModel.handle(.deleteInteraction(interaction.id))
                    }
                } ) {
                    Text("Delete all interactions")
                }
            } label: {
                Image(.flowerNav)
                    .resizable()
                    .frame(width: <->20.11, height: |19.5)
            }
            Spacer()
        }
        .frame(height: |40)
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.white, .clear], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: 30)
                .offset(y: 70)
                .blur(radius: 5)
        }
    }
    
    @ViewBuilder
    var favourites: some View {
        let cellSize = CGSize(width: <->79.74, height: |90.46)

        ScrollViewWrapper(
            contentOffset: gridContentOffset,
            contentSize: gridContentSize,
            size: gridContainerSize,
            zoomScale: gridZoomScale,
            animationDuration: 0.35,
            minZoomLevel: 0.3,
            contentId: viewModel.uiState.contentIdentifier
        ) {
            HexGrid(
                viewModel.state.gridItemsToDisplay,
                spacing: 8,
                cornerRadius: 6,
                fixedCellSize: cellSize,
                indentLine: viewModel.state.onboardingFinished ? .odd : .even,
                content: { cell in
                    if viewModel.state.onboardingFinished {
                        view(for: cell, cellSize: cellSize)
                    } else {
                        onboardingView(for: cell, cellSize: cellSize)
                    }
                },
                overlay: hexOverlayView
            )
            .padding(.bottom, viewModel.state.onboardingFinished ? 200 : 0)
            .background { Color.appBackground }
        }
        .sizeInfo(size: gridContainerSize)
        .background { Color.appBackground }
        .overlay(alignment: .top) {
            LinearGradient(colors: [.appBackground, .clear], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: 50)
                .blur(radius: 1)
                .offset(y: -10.0)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.clear, .appBackground], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: 50)
                .blur(radius: 1)
                .offset(y: 10.0)
                .allowsHitTesting(false)
        }
    }
    
    @ViewBuilder
    var allContacts: some View {
        EquatableView(content: ContactList(
            listToDisplay: viewModel.state.listToDisplay,
            isRefreshActive: !viewModel.state.isSearching,
            onRowTapped: { viewModel.handle(.goToDetails(contact: $0, point: $1)) },
            onInteraction: { viewModel.handle(.interact($0, .create)) },
            onRefresh: { viewModel.handle(.isSearching(true)) }
        ) )
        .overlay {
            if viewModel.state.listToDisplay.isEmpty {
                addContact
            }
        }
    }
    
    @ViewBuilder
    var onboarding: some View {
        ScrollView {
            Image(.swipeUp)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: |57)
                .padding(.top, 27)
            
            SyncContactsPopup(action: {
                viewModel.handle(.requestAccess)
            }, onDismiss: {
                viewModel.handle(.continueRealm)
            })
            .frame(height: 200)
        }
    }
}

// MARK: - View for Cells
extension HomeView {
    private func getFavoriteForGridCell(_ cell: HexCell) -> Contact? {
        guard let priority = cell.priority else { return nil }
        let favoriteCount = viewModel.state.favorites?.count ?? 0
        guard priority < favoriteCount && priority >= 0 else { return nil }
        return viewModel.state.favorites?[priority]
    }
    
    private func getInteractionForGridCell(_ cell: HexCell) -> ContactInteraction? {
        guard let priority = cell.priority else { return nil }
        let position = priority
        let interactionPriority = position
        return viewModel.state.interactions.first(where: { $0.priority == interactionPriority })
    }

    @ViewBuilder
    private func view(for cell: HexCell, cellSize: CGSize) -> some View {
        ZStack {
            if cell.offsetCoordinate.row == 0, cell.offsetCoordinate.col == 0 {
                if let isMeContact = viewModel.state.isMe {
                    AvatarHexCell(contact: isMeContact, color: .clear) { point in
                        viewModel.handle(.goToDetails(contact: isMeContact, point: point))
                    }
//                    .matchedTransitionSource(id: isMeContact.id, in: namespace)
                } else {
                    Button {
                        viewModel.handle(.goToProfile)
                    } label: {
                        ColorHexCell(color: .appPurple)
                            .overlay {
                                Image(.plusIcon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .scaledToFit()
                            }
                    }
                }
            } else if let contact = getFavoriteForGridCell(cell) {
                AvatarHexCell(contact: contact, color: .clear) { point in
                    viewModel.handle(.goToDetails(contact: contact, point: point))
                }
            } else if let interaction = getInteractionForGridCell(cell),
                      let contact = viewModel.getInteractionValues(for: interaction)?.contact {
                AvatarHexCell(contact: contact, color: .clear) { point in
                    viewModel.handle(.perform(interaction))
                }
                .onDrag({ return .init(object: interaction.id as NSString) }) {
                    AvatarHexCell(contact: contact, color: .clear, size: cellSize) { _ in }
                        .frame(width: cellSize.width, height: cellSize.height)
                        .contentShape(.dragPreview, HexagonShape(cornerRadius: 6))
                        .onAppear {
                            isDragging.wrappedValue = true
                        }
                }
            } else if (cell.priority?.isMultiple(of: 12) ?? false) && cell.priority != 0 && isDragging.wrappedValue {
                ColorHexCell(color: .red.opacity(0.5))
                    .overlay {
                        #warning("Use a new icon when we are given one.")
                        Image(.trashOutline)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 42, height: 42)
                            .foregroundStyle(.white)
                            .allowsHitTesting(false)
                    }
                .onDrop(
                    of: [.text],
                    delegate: InteractionDropDelegate(
                        onDrop: { id in
                            didDrop.wrappedValue.toggle()
                            viewModel.handle(.deleteInteraction(id))
                        }
                    )
                )
            } else {
                ColorHexCell(color: cell.color)
                    .contentShape(.dragPreview, HexagonShape(cornerRadius: 6))
                    .onDrag({
                        guard let priority = cell.priority else { return .init() }
                        let item = NSString(format: "%d", priority)
                        return .init(object: item)
                    }) {
                        ColorHexCell(color: cell.color)
                            .frame(width: cellSize.width, height: cellSize.height)
                            .contentShape(.dragPreview, HexagonShape(cornerRadius: 6))
                    }
                    .onTapGesture {
                        withAnimation {
                            viewModel.handle(.toggleFullscreen)
                        }
                    }
            }
            
            if cell.isSelected {
                Color.teal.opacity(0.3)
            }
        }
        .onDrop(
            of: [.text],
            delegate: InteractionDropDelegate(
                onDrop: { id in
                    didDrop.wrappedValue.toggle()
                    if let priority = Int(id) {
                        viewModel.handle(.swapHexagons(cell.priority, priority))
                        return
                    }

                    viewModel.handle(.moveInteraction(id: id, toPriority: cell.priority))
                },
                onTarget: { onTarget(isTargeted: $0, cell: cell) }
            )
        )
        .getCellCenter(cellToGet: viewModel.state.cellToGet, thisCell: cell.priority) { position in
            viewModel.handle(.goToOffset(position, UIScreen.main.bounds))
        }
        .overlay {
            if false { // For development
                ZStack {
                    Color.red.opacity(0.5)
                    VStack {
                        Text("\(cell.offsetCoordinate.row), \(cell.offsetCoordinate.col)")
                            .foregroundStyle(.white)
                        Text(cell.priority?.description ?? "")
                            .foregroundStyle(.white)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom)
                    }
                }
            }
        }
        .contentShape(HexagonShape(cornerRadius: 6))
    }
    
    private func onTarget(isTargeted: Bool, cell: HexCell) {
        if isTargeted {
            targetedHex.wrappedValue = cell
        } else {
            targetedHex.wrappedValue = nil
        }
    }
    
    private func resetAnimationProperties() {
        hexTargetView = nil
        targetedHexPos = nil
        swapperPos = nil
    }
    
    @ViewBuilder
    private func onboardingView(for cell: HexCell, cellSize: CGSize) -> some View {
        ZStack {
            if cell.offsetCoordinate.row == 4 && cell.offsetCoordinate.col == 2 {
                AvatarHexCell(
                    contact: Contact(
                        id: "",
                        imageData: viewModel.uiState.onboardingProfilePicture
                    ),
                    color: Color.appPurple,
                    size: .init(width: <->26.37, height: |30.7)
                )
            } else {
                ColorHexCell(color: cell.color)
            }
        }
    }
    
    @ViewBuilder
    var addContact: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("\"\(viewModel.state.searchedTerm)\"")
                    .foregroundColor(.white)
                    .font(.montserat(size: 20, weight: .semibold))
                
                Text("There is nothing to show on your contact list")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.montserat(size: 18))
                    .multilineTextAlignment(.center)
                
                Button {
                    viewModel.handle(.addContact)
                } label: {
                    HStack(spacing: 8) {
                        Rectangle()
                            .frame(width: 15, height: 1.5)
                            .foregroundColor(.appGreen)
                            .frame(height: 15)
                            .overlay {
                                Rectangle()
                                    .frame(width: 1.5, height: 15)
                                    .foregroundColor(.appGreen)
                            }
                        Text("Create New Contact")
                            .foregroundColor(.appGreen)
                            .font(.montserat(size: 18))
                    }
                }.buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.top, 30)
            .frame(maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private func hexOverlayView(for cell: HexCell) -> some View {
        if let _ = getFavoriteForGridCell(cell) {
            hexFavoriteIconOverlay
        } else if let interaction = getInteractionForGridCell(cell),
                  let value = viewModel.getInteractionValues(for: interaction)?.value {
            interactionOverlay(id: interaction.id, value: value)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder 
    private var hexFavoriteIconOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HexCircleIcon(image: .startFillIcon, background: .appYellow)
                    .padding(.bottom, 6)
                    .padding(.trailing, 8)
            }
        }
    }
    
    @ViewBuilder
    private func interactionOverlay(id: String, value: LabeledValue) -> some View {
        VStack { }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topTrailing) {
                if isEditing.wrappedValue {
                    Button(action: {
                        withAnimation {
                            viewModel.handle(.deleteInteraction(id))
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: <->24, height: |24)
                    }
                    .padding(.top, 12)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                let interactionPresentable = ContactInteractionPresentable(value: value)
                HexCircleIcon(image: interactionPresentable.image, background: interactionPresentable.background)
                    .padding(.bottom, 6)
                    .padding(.trailing, 8)
            }
    }
}

// MARK: - Bindings
extension HomeView {
    private var sheetSize: Binding<CGSize> {
        .init(
            get: { viewModel.uiState.sheetSize },
            set: { viewModel.handle(.setSheetSize($0)) }
        )
    }
    
    private var gridContainerSize: Binding<CGSize> {
        .init(
            get: { viewModel.uiState.gridContainerSize },
            set: { viewModel.handle(.setGridContainerSize($0)) }
        )
    }
    
    private var gridZoomScale: Binding<CGFloat> {
        .init(
            get: { viewModel.uiState.gridZoomScale },
            set: { viewModel.handle(.setGridZoomScale($0)) }
        )
    }
    
    private var gridContentOffset: Binding<CGPoint> {
        .init(
            get: { viewModel.uiState.gridContentOffset },
            set: { viewModel.handle(.setGridContentOffset($0)) }
        )
    }
    
    private var gridContentSize: Binding<CGSize> {
        .init(
            get: { viewModel.uiState.gridContentSize },
            set: { viewModel.handle(.setGridContentSize($0)) }
        )
    }

    private var detent: Binding<PresentationDetent> {
        .init(
            get: { viewModel.state.detent },
            set: { viewModel.handle(.setDetent($0)) }
        )
    }

    private var headerSize: Binding<CGSize> {
        .init(
            get: { viewModel.uiState.headerSize },
            set: { viewModel.handle(.headerSize($0)) }
        )
    }
    
    private var drawerIsOpen: Binding<Bool> {
        .init(
            get: { viewModel.uiState.drawerIsOpen },
            set: { viewModel.handle(.setDrawerOpen($0)) }
        )
    }
    
    private var isSearching: Binding<Bool> {
        .init(
            get: { viewModel.state.isSearching },
            set: { viewModel.handle(.isSearching($0)) }
        )
    }
    
    private var searchTerm: Binding<String> {
        .init(
            get: { viewModel.state.searchedTerm },
            set: { viewModel.handle(.searchTerm($0)) }
        )
    }
    
    private var isEditing: Binding<Bool> {
        .init(
            get: { viewModel.uiState.isEditing },
            set: { viewModel.handle(.setIsEditing($0)) }
        )
    }
    
    private var isDragging: Binding<Bool> {
        .init(
            get: { viewModel.uiState.isDraggingAHexagon },
            set: { viewModel.handle(.isDraggingAHexagon($0)) }
        )
    }
    
    private var didDrop: Binding<Bool> {
        .init(
            get: { viewModel.uiState.didDropDraggedHexagon },
            set: { viewModel.handle(.didDropDraggedHexagon($0)) }
        )
    }
    
    private var targetedHex: Binding<HexCell?> {
        .init(
            get: { viewModel.state.gridItems.first(where: { $0.isSelected }) },
            set: { viewModel.handle(.targetHexagon($0)) }
        )
    }
    
    private var showMergeAlert: Binding<Bool> {
        .init(
            get: { viewModel.state.shouldAskRealmMerge },
            set: { viewModel.handle(.askForRealmMerge($0)) }
        )
    }
    
    private var showSettingsAlert: Binding<Bool> {
        .init(
            get: { viewModel.state.showSettingsAlert },
            set: { viewModel.handle(.showSettingsAlert($0)) }
        )
    }
}
