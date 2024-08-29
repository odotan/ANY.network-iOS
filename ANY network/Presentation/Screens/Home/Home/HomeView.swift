import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            
            favourites
                .bottomDrawerView(contentHeight: drawerContentHeight){
                    VStack {
                        if !viewModel.state.onboardingFinished {
                            onboarding
                            Spacer()
                        } else if viewModel.state.showAll {
                            allContacts
                        }
                    }
                    .padding(.top)
                }
                .onAppear {
                    let height = viewModel.state.onboardingFinished ? 180 : UIScreen.main.bounds.height - 250
                    drawerContentHeight.wrappedValue = height
                }
        }
        .task {
            viewModel.handle(.getAllContacts)
        }
        .task {
            viewModel.handle(.getFavoriteContacts)
        }
        .onChange(of: viewModel.state.gridItems) { oldValue, newValue in
            isSheetPresented.wrappedValue = newValue != nil && !newValue!.isEmpty
        }
        .onAppear { viewModel.handle(.sheetPresentationUpdated(to: true)) }
        .onDisappear { viewModel.handle(.sheetPresentationUpdated(to: false)) }
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
            animationDuration: 0.35,
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
//                testView(for: cell)
            }
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
        .onChange(of: viewModel.uiState.gridContentSize) { old, new in
            guard old == .zero else { return }
            viewModel.handle(.recenter(false))
        }
        .overlay(alignment: .bottomLeading) {
            if viewModel.state.onboardingFinished {
                HStack {
                    SearchButton {
                        viewModel.handle(.goToSearch)
                    }
                    
                    Spacer()
                    
                    RecenterButton {
                        viewModel.handle(.recenter(true))
                    }
                }
                .padding(.bottom, 50)
                .padding(.horizontal, <->18)
            }
        }
    }
    
    @ViewBuilder
    var allContacts: some View {
        List(viewModel.state.list!) { contact in
            Button {
                viewModel.handle(.goToDetails(contact: contact))
            } label: {
                ContactCell(contact: contact)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listRowSpacing(-10)
        .listStyle(.plain)
    }
    
    @ViewBuilder
    var onboarding: some View {
        VStack(spacing: 0) {
            Image(.swipeUp)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: |57)
                    .padding(.top, 27)
                    .padding(.bottom, 30)

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
            } else {
                ColorHexCell(color: cell.color)
            }
        }
        .captureCenterPoint { point in
            if cell.offsetCoordinate.row == 0 && cell.offsetCoordinate.col == 0 {
                viewModel.handle(.setCenterPosition(.init(x: point.x, y: point.y - cellSize.height / 2)))
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
        .captureCenterPoint { point in
            if cell.offsetCoordinate.row == 4 && cell.offsetCoordinate.col == 2 {
                viewModel.handle(.setCenterPosition(.init(x: point.x, y: point.y - cellSize.height / 2)))
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
}

// MARK: - Bindings
extension HomeView {
    private var isSheetPresented: Binding<Bool> {
        return Binding(
            get: { viewModel.state.isSheetPresented },
            set: { viewModel.handle(.sheetPresentationUpdated(to: $0)) }
        )
    }

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
    
    private var drawerContentHeight: Binding<CGFloat> {
        .init(
            get: { viewModel.uiState.drawerContentHeight },
            set: { viewModel.handle(.setDrawerContentHeight($0)) }
        )
    }
    
    private var headerSize: Binding<CGSize> {
        .init(
            get: { viewModel.uiState.headerSize },
            set: { viewModel.handle(.headerSize($0)) }
        )
    }
}

extension PresentationDetent {
    static var bottom: PresentationDetent { .height(60) }
    static var middle: PresentationDetent { .height(482) }
    static var top: PresentationDetent { .height(600) }
}
