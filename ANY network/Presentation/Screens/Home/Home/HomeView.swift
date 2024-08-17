import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
                .overlay(alignment: .bottom) {
                    LinearGradient(colors: [.white, .clear], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                        .offset(y: 80)
                        .frame(height: 30)
                        .blur(radius: 5)
                }
            
            favourites
                .onChange(of: viewModel.uiState.gridContentSize) { old, new in
                    guard old == .zero else { return }
                    viewModel.handle(.recenter)
                }
                .overlay(alignment: .bottomLeading) {
                    HStack {
                        SearchButton {
                            viewModel.handle(.goToSearch)
                        }
                        
                        Spacer()
                        
                        RecenterButton {
                            viewModel.handle(.recenter)
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, <->18)
                }
            
            Spacer()
                .frame(height: sheetSize.wrappedValue.height + 20) // 20 is the size of the corner radius of the sheet
        }
        .sheet(isPresented: isSheetPresented) {
            VStack {
                if viewModel.state.showAll {
                    allContacts
                }
            }
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .presentationDetents([.bottom, .middle, .top], selection: detent)
            .presentationCornerRadius(20)
            .presentationBackground(Color.appBackground)
            .presentationBackgroundInteraction(.enabled)
            .presentationContentInteraction(.scrolls)
            .ignoresSafeArea()
            .sizeInfo(size: sheetSize)
        }
//        .task {
//            viewModel.handle(.getAllContacts)
//        }
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
            HexGrid(viewModel.state.gridItems, spacing: 8, cornerRadius: 6, fixedCellSize: cellSize, indentLine: .odd) { cell in
                if
                    let priority = cell.priority,
                    priority < (viewModel.state.favorites?.count ?? 0),
                    let contact = viewModel.state.favorites?[priority] {
                    AvatarHexCell(imageData: contact.imageData, color: .clear) {
                        viewModel.handle(.goToDetails(contact: contact))
                    }
//                    ColorHexCell(color: cell.color)
                } else {
//                    Color.green
//                        .overlay {
//                            Text("\(cell.priority ?? -1)")
//                                .font(.title)
//                                .colorMultiply(.white)
//                        }
                    ColorHexCell(color: cell.color)
                }
            }
            .background { Color.appBackground }
        }
        .background { Color.appBackground }
        .overlay(alignment: .top) {
            LinearGradient(colors: [.appBackground, .clear], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: 50)
                .blur(radius: 1)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.clear, .appBackground], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: 50)
                .blur(radius: 1)
                .allowsHitTesting(false)
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
        .background(.appBackground)
    }
}

extension PresentationDetent {
    static var bottom: PresentationDetent { .height(60) }
    static var middle: PresentationDetent { .height(482) }
    static var top: PresentationDetent { .height(600) }
}

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
         
//    private var list: Binding<[HexCell]> {
//        .init(
//            get: { viewModel.state.gridItems },
//            set: { viewModel.handle(.setGridItems($0)) }
//        )
//    }
    
    private var detent: Binding<PresentationDetent> {
        .init(
            get: { viewModel.state.detent },
            set: { viewModel.handle(.setDetent($0)) }
        )
    }
}
