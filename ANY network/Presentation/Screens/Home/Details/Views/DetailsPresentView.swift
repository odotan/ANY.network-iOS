import SwiftUI
import Combine

@MainActor
struct DetailsPresentView: View {
    typealias CellView = View
    typealias CellDatasource = ((HexCell, AnyView) -> AnyView)

    private let shouldDismissParentView: PassthroughSubject<Void, Never>?

    // Grid
    private let ratio: CGFloat = 518 / UIScreen.main.bounds.width * <->1
    @State private var gridSize: CGSize = .zero
    @State private var gridZoomScale: CGFloat = 518 / UIScreen.main.bounds.width * <->1
    @State private var gridContentOffset: CGPoint = .zero
    @State private var gridContainerSize: CGSize = .zero
    @State private var gridContentSize: CGSize = .zero
    @State private var gridUserInteracting: Bool = false
    
    // Sticky buttons' properties
    @State private var plusPosition: CGPoint = .zero
    @State private var plusSize: CGSize = .zero
    @State private var favoritePosition: CGPoint = .zero
    @State private var favoriteSize: CGSize = .zero
    
    @Binding private var isEditing: Bool
    @State private var shakeAnimation: Bool = false
    @State private var didLoad: Bool = false
    private let contactDatasource: () -> Contact
    private let performAction: (any ContactAction) -> Void
    private let toggleFavouriteAction: ToggleFavouriteAction
    private let cellDatasource: CellDatasource
    
    var contact: Contact {
        contactDatasource()
    }
    
    init(
        isEditing: Binding<Bool>,
        shouldDismissParentView: PassthroughSubject<Void, Never>? = nil,
        toggleFavouriteAction: ToggleFavouriteAction,
        contact contactDatasource: @escaping () -> Contact,
        performAction: @escaping (any ContactAction) -> Void,
        cellDatasource: @escaping CellDatasource
    ) {
        self._isEditing = isEditing
        self.toggleFavouriteAction = toggleFavouriteAction
        self.shouldDismissParentView = shouldDismissParentView
        self.contactDatasource = contactDatasource
        self.performAction = performAction
        self.cellDatasource = cellDatasource
    }

    var body: some View {
        let width = 518 / 6 / ratio
        let cellSize = CGSize(width: width, height: width * 1.1258)
        
        GeometryReader { reader in
            ScrollViewWrapper(
                contentOffset: $gridContentOffset,
                contentSize: $gridContentSize,
                size: $gridContainerSize,
                zoomScale: $gridZoomScale,
                userInteracting: $gridUserInteracting,
                animationDuration: 0.35,
                contentId: UUID()
            ) {
                HexGrid(HexCell.all, spacing: 8, cornerRadius: 8, fixedCellSize: cellSize) { cell in
                    cellDatasource(
                        cell,
                        
                        AnyView(
                            cellView(for: cell)
                        )
                    )
                }
                .background { Color.appBackground }
            }
        }
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.clear, Color(hex: "120E1E")!], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: |145)
                .frame(maxWidth: .infinity)
        }
        .overlay {
            IconHexCell(type: .plus) {
                
            }
            .frame(width: plusSize.width * ratio, height: plusSize.height * ratio)
            .clipShape(HexagonShape(cornerRadius: 8))
            .position(plusPosition)
            .opacity(didLoad ? 1 : 0)
        }
        .overlay {
            IconHexCell(type: .favorite(filled: contact.isFavorite), imageSize: CGSize(width: 32, height: 32)) {
                performAction(toggleFavouriteAction)
            }
            .frame(width: plusSize.width * ratio, height: plusSize.height * ratio)
//            .scaleEffect(ratio)
            .clipShape(HexagonShape(cornerRadius: 8))
            .position(favoritePosition)
            .opacity(didLoad ? 1 : 0)
        }
        .onChange(of: gridContentSize) { _, newValue in
            // Center the grid
            let contentOffset = CGPoint(x: (newValue.width - gridContainerSize.width) / 2  , y: (newValue.height - gridContainerSize.height) / 2)
            gridContentOffset = contentOffset
        }
        .onChange(of: gridZoomScale, { _, newValue in
            if newValue < 0.6 { shouldDismissParentView?.send() }
        })
        .onChange(of: isEditing, { oldValue, newValue in
            if oldValue != newValue && newValue {
                gridZoomScale = ratio
                let contentOffset = CGPoint(x: (gridContentSize.width - gridContainerSize.width) / 2  , y: (gridContentSize.height - gridContainerSize.height) / 2)
                gridContentOffset = contentOffset
            }
        })
        .onAppear(perform: {
            withAnimation {
                didLoad = true
            }
        })
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func cellView(for cell: HexCell) -> some View {
        switch (cell.offsetCoordinate.row, cell.offsetCoordinate.col) {
        case (4, 2):
            AvatarHexCell(imageData: contact.imageData, color: cell.color)
        case (5, 2):
            Group {
                if !contact.phoneNumbers.isEmpty {
                    IconHexCell(type: .phone) {
                        performAction(PhoneNumberAction(value: contact.phoneNumbers.first?.value ?? ""))
                    }
                } else {
                    ColorHexCell(color: cell.color)
                }
            }
        case (5, 3):
            Group {
                if !contact.emailAddresses.isEmpty {
                    IconHexCell(type: .email) {
                        performAction(EmailAction(value: contact.emailAddresses.first?.value ?? ""))
                    }
                } else {
                    ColorHexCell(color: cell.color)
                }
            }
        case (10, 1): // Plus icon
            ColorHexCell(color: .clear)
                .sizeInfo(size: $plusSize)
                .captureCenterPoint {
                    let contentOffset = CGPoint(x: (gridContentSize.width - gridContainerSize.width) / 2  , y: (gridContentSize.height - gridContainerSize.height) / 2)

                    if didLoad && gridContentOffset == contentOffset && gridZoomScale == ratio {
                        plusPosition = $0
                    }
                }
        case (10, 3): // Favorite
            ColorHexCell(color: .clear)
                .sizeInfo(size: $favoriteSize)
                .captureCenterPoint {
                    let contentOffset = CGPoint(x: (gridContentSize.width - gridContainerSize.width) / 2  , y: (gridContentSize.height - gridContainerSize.height) / 2)

                    if didLoad && gridContentOffset == contentOffset && gridZoomScale == ratio {
                        favoritePosition = $0
                    }
                }
        default:
            ColorHexCell(color: cell.color)
        }
    }
}
