import SwiftUI
import Combine

struct DetailsPresentView: View {
    typealias CellView = View
    typealias CellDatasource = ((HexCell, AnyView) -> AnyView)

    private let shouldDismissParentView: PassthroughSubject<Void, Never>?

    // Grid
    @State private var gridSize: CGSize = .zero
    @State private var gridZoomScale: CGFloat = 1
    @State private var gridContentOffset: CGPoint = .zero
    @State private var gridContainerSize: CGSize = .zero
    @State private var gridContentSize: CGSize = .zero
    
    // Sticky buttons' properties
    @State private var plusPosition: CGPoint = .zero
    @State private var plusSize: CGSize = .zero
    @State private var favoritePosition: CGPoint = .zero
    @State private var favoriteSize: CGSize = .zero
    
    @Binding private var isEditing: Bool
    @State private var shakeAnimation: Bool = false
    private let contactDatasource: () -> Contact
    private let performAction: (DetailsViewModel.Action) -> Void
    private let cellDatasource: CellDatasource
    
    var contact: Contact {
        contactDatasource()
    }
    
    init(
        isEditing: Binding<Bool>,
        shouldDismissParentView: PassthroughSubject<Void, Never>? = nil,
        contact contactDatasource: @escaping () -> Contact,
        performAction: @escaping (DetailsViewModel.Action) -> Void,
        cellDatasource: @escaping CellDatasource
    ) {
        self._isEditing = isEditing
        self.shouldDismissParentView = shouldDismissParentView
        self.contactDatasource = contactDatasource
        self.performAction = performAction
        self.cellDatasource = cellDatasource
    }

    var body: some View {
        let cellSize = CGSize(width: <->79.93, height: |89.99)
        
        ScrollViewWrapper(
            contentOffset: $gridContentOffset,
            contentSize: $gridContentSize,
            size: $gridContainerSize,
            zoomScale: $gridZoomScale,
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
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.clear, Color(hex: "120E1E")!], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: |145)
                .frame(maxWidth: .infinity)
        }
        .overlay {
            IconHexCell(type: .plus) {
                
            }
            .frame(width: plusSize.width, height: plusSize.height)
            .clipShape(HexagonShape(cornerRadius: 8))
            .position(plusPosition)
        }
        .overlay {
            IconHexCell(type: .favorite(filled: contact.isFavorite), imageSize: CGSize(width: 32, height: 32)) {
                performAction(.favoriteToggle)
            }
            .frame(width: favoriteSize.width, height: favoriteSize.height)
            .clipShape(HexagonShape(cornerRadius: 8))
            .position(favoritePosition)
        }
        .onChange(of: gridZoomScale, { _, newValue in
            if newValue < 0.6 { shouldDismissParentView?.send() }
        })
        .onChange(of: isEditing, { oldValue, newValue in
            if oldValue != newValue && newValue {
                gridZoomScale = 1
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
                        performAction(.phone)
                    }
                } else {
                    ColorHexCell(color: cell.color)
                }
            }
        case (5, 3):
            Group {
                if !contact.emailAddresses.isEmpty {
                    IconHexCell(type: .email) {
                        performAction(.email)
                    }
                } else {
                    ColorHexCell(color: cell.color)
                }
            }
        case (10, 1): // Plus icon
            ColorHexCell(color: cell.color)
                .sizeInfo(size: $plusSize)
                .captureCenterPoint {
//                    guard plusPosition == .zero else { return }
                    plusPosition = $0
                }
        case (10, 3): // Favorite
            ColorHexCell(color: cell.color)
                .sizeInfo(size: $favoriteSize)
                .captureCenterPoint {
//                    guard favoritePosition == .zero else { return }
                    favoritePosition = $0
                }
        default:
            ColorHexCell(color: cell.color)
        }
    }
}
