import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    // Sizes
    @State private var screenSize: CGSize = .zero
    @State private var sheetSize: CGSize = .zero
    @State private var gridContainerSize: CGSize = .zero
    
    // Grid
    @State private var gridSize: CGSize = .zero
    @State private var gridZoomScale: CGFloat = 1
    @State private var gridContentOffset: CGPoint = .zero
    @State private var gridContentSize: CGSize = .zero
    
    // Sheet
    @State private var detentSelected: PresentationDetent = .top
    
    @State var list: [HexCell] = HexCell.inline

    
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
                .onChange(of: gridContentSize) { old, new in
                    guard old == .zero else { return }
                    gridContentOffset = CGPoint(
                        x: (new.width - gridContainerSize.width) / 2 ,
                        y: (new.height - gridContainerSize.height) / 2
                    )
                }
                .overlay(alignment: .bottom) {
                    HStack {
                        SearchButton {
                            viewModel.handle(.goToSearch)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, <->18)
                }
            
            Spacer()
                .frame(height: sheetSize.height + 20) // 20 is the size of the corner radius of the sheet
        }
        .sheet(isPresented: isSheetPresented) {
            VStack {
                if viewModel.state.showAll {
                    allAndSearchedList
                }
            }
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .presentationDetents([.bottom, .middle, .top], selection: $detentSelected)
            .presentationCornerRadius(20)
            .presentationBackground(Color.appBackground)
            .presentationBackgroundInteraction(.enabled)
            .presentationContentInteraction(.scrolls)
            .ignoresSafeArea()
            .sizeInfo(size: $sheetSize)
        }
        .onChange(of: detentSelected) { _ , newValue in
            switch detentSelected {
            case .top:
                list = HexCell.inline
            case .middle:
                list = HexCell.middle
            case .bottom:
                list = HexCell.all
            default:
                list = [HexCell]()
            }
        }
        .task {
            viewModel.handle(.getAllContacts)
        }
//        .task {
//            viewModel.handle(.getFavoriteContacts)
//        }
        .onChange(of: viewModel.state.list) { oldValue, newValue in
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
            contentOffset: $gridContentOffset,
            contentSize: $gridContentSize,
            size: $gridContainerSize,
            zoomScale: $gridZoomScale,
            animationDuration: 0.35
        ) {
            HexGrid(list, spacing: 8, cornerRadius: 6, fixedCellSize: cellSize) { cell in
                Color.appRaisinBlack
            }
            .background { Color.appBackground }
        }
        .background { Color.appBackground }
        .overlay(alignment: .top) {
            LinearGradient(colors: [.appBackground, .clear], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: 50)
                .blur(radius: 1)
        }
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.clear, .appBackground], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: 50)
                .blur(radius: 1)
        }
    }
    
    @ViewBuilder
    var allAndSearchedList: some View {
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

    private var isSheetPresented: Binding<Bool> {
        return Binding(
            get: { viewModel.state.isSheetPresented },
            set: { viewModel.handle(.sheetPresentationUpdated(to: $0)) }
        )
    }
}

extension PresentationDetent {
    @MainActor static var bottom: PresentationDetent { .height(|60) }
    @MainActor static var middle: PresentationDetent { .height(|482) }
    @MainActor static var top: PresentationDetent { .height(|600) }
}
