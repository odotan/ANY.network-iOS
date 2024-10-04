import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

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
            header
            
            favourites
                .sheet(isPresented: drawerIsOpen) {
                    VStack {
                        if !viewModel.state.onboardingFinished {
                            onboarding
                        } else if viewModel.state.isSearching {
                            allContacts
                                .searchTextField(text: searchTerm) {
                                    viewModel.handle(.addContact)
                                }
                        } else if viewModel.state.showAll {
                            allContacts
                        }
                    }
                    .sizeInfo(size: sheetSize)
                    .padding(.top)
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .presentationBackground(.clear)
                            .background(Color.appBackground.opacity(0.1))
                            .ignoresSafeArea()
                    )
                    .overlay {
                        if !isSearching.wrappedValue && viewModel.state.onboardingFinished {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    SearchButton(action: { isSearching.wrappedValue = true })

                                    Spacer()
                                    RecenterButton(action: { viewModel.handle(.recenter(true)) })

                                    Spacer()
                                }
                            }
                            .padding(.bottom)
                        }
                    }
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
    
    }
    
    @ViewBuilder
    var header: some View {
        HStack(spacing: 0) {
            Spacer()
            
            Image(.flowerNav)
                .resizable()
                .frame(width: <->20.11, height: |19.5)

            Spacer()
        }
        .frame(height: |40)
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.white, .clear], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: 30)
                .offset(y: 70)
                .blur(radius: 5)
        }
        .sizeInfo(size: headerSize)
    }
    
    @ViewBuilder
    var favourites: some View {
        let cellSize = CGSize(width: <->79.74, height: |90.46)

        ScrollViewWrapper(
            contentOffset: gridContentOffset,
            contentSize: gridContentSize,
            size: gridContainerSize,
            zoomScale: gridZoomScale,
            userInteracting: gridUserInteracting,
            animationDuration: 0.35,
            minZoomLevel: 0.3,
            contentId: viewModel.uiState.contentIdentifier
        ) {
            HexGrid(
                viewModel.state.gridItemsToDisplay,
                spacing: 8,
                cornerRadius: 6,
                fixedCellSize: cellSize,
                indentLine: viewModel.state.onboardingFinished ? .odd : .even
            ) { cell in
                if viewModel.state.onboardingFinished {
                    view(for: cell, cellSize: cellSize)
                } else {
                    onboardingView(for: cell, cellSize: cellSize)
                }
            }
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
//        ScrollView {
//            LazyVStack(spacing: 24) {
//                ForEach(viewModel.state.list!) { contact in
//                    Button {
//                        viewModel.handle(.goToDetails(contact: contact))
//                    } label: {
//                        ContactCell(contact: contact)
//                            .id(contact.id)
//                    }
//                    .padding(.horizontal, 16)
//                }
//            }
//            .padding(.top)
//        }
//        if !viewModel.state.listToDisplay.isEmpty {
            List(viewModel.state.listToDisplay) { contact in
                Button {
                    viewModel.handle(.goToDetails(contact: contact))
                } label: {
                    ContactCell(contact: contact)
                        .id(contact.id)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .overlay {
                if viewModel.state.listToDisplay.isEmpty {
                    addContact
                }
            }
            .refreshable(isActive: !viewModel.state.isSearching) {
                viewModel.handle(.isSearching(true))
            }
            .listRowSpacing(-10)
            .listStyle(.plain)
//        } else {
//            addContact
//        }
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
//                    .padding(.bottom, 20)

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
    @ViewBuilder
    private func view(for cell: HexCell, cellSize: CGSize) -> some View {
        ZStack {
            if
                let priority = cell.priority,
                priority < (viewModel.state.favorites?.count ?? 0),
                let contact = viewModel.state.favorites?[priority] {
                AvatarHexCell(imageData: contact.imageData, color: .clear) {
                    viewModel.handle(.goToDetails(contact: contact))
                }
                .captureCenterPoint { point in
//                    if cell.offsetCoordinate.row == 0 && cell.offsetCoordinate.col == 0 {
                        viewModel.handle(.setCenterPosition(.init(x: point.x, y: point.y - cellSize.height / 2)))
//                    }
                }
            } else {
                let offset = (row: -4, col: -2) // The offset we need to put 4, 2 from `HexCell.all` in the center
                if let defaultBackgroundCell = HexCell.all.first(where: {
                    $0.offsetCoordinate.row == (cell.offsetCoordinate.row - offset.row) &&
                    $0.offsetCoordinate.col == (cell.offsetCoordinate.col - offset.col + (cell.offsetCoordinate.row % 2 != 0 ? 1 : 0))
                }) {
                    ColorHexCell(color: defaultBackgroundCell.color)
                } else {
                    ColorHexCell(
                        color: Color(
                            red: .random(in: 0...1),
                            green: .random(in: 0...1),
                            blue: .random(in: 0...1),
                            opacity: .random(in: 0.015...0.035)
                        )
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private func onboardingView(for cell: HexCell, cellSize: CGSize) -> some View {
        ZStack {
            if cell.offsetCoordinate.row == 4 && cell.offsetCoordinate.col == 2 {
                AvatarHexCell(color: Color.appPurple)
            } else {
                ColorHexCell(color: cell.color)
            }
        }
    }
    
    @ViewBuilder
    private func testView(for cell: HexCell) -> some View {
        Color.green
            .overlay {
                Text("\(cell.priority ?? -1) \(cell.offsetCoordinate.row)/\(cell.offsetCoordinate.col)")
                    .font(.subheadline)
                    .colorMultiply(.white)
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
    
    private var gridUserInteracting: Binding<Bool> {
        .init(
            get: { viewModel.uiState.gridUserInteracting },
            set: { viewModel.handle(.gridUserInteracting($0)) }
        )
    }
}

fileprivate extension View {
    @ViewBuilder
    func refreshable(isActive: Bool, action: @escaping () -> Void) -> some View {
        if isActive {
            self.refreshable { action() }
        } else {
            self
        }
    }
}
