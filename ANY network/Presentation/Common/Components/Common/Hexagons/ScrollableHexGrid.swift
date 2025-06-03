import SwiftUI

struct ScrollableHexGrid: View {
    private let content: ((HexCell) -> AnyView)?
    private let overlay: ((HexCell) -> AnyView)?
    @ObservedObject var viewModel: ScrollableHexGridModel

    init(viewModel: ScrollableHexGridModel, content: ((HexCell) -> AnyView)? = nil, overlay: ((HexCell) -> AnyView)? = nil) {
        self.viewModel = viewModel
        self.content = content
        self.overlay = overlay
    }

    var body: some View {
        ScrollViewWrapper(
            contentOffset: $viewModel.gridContentOffset,
            contentSize: $viewModel.gridContentSize,
            size: $viewModel.gridContainerSize,
            zoomScale: $viewModel.gridZoomScale,
            scrollEnabled: viewModel.scrollEnabled,
            animationDuration: 0.35,
            minZoomLevel: 0.3,
            contentId: viewModel.refreshID
        ) {
            HexGrid(
                viewModel.gridItems,
                spacing: 8,
                cornerRadius: 8,
                fixedCellSize: viewModel.cellSize,
                indentLine: .odd,
                content: { item in
                    if let content = content {
                        content(item)
                            .id(item.offsetCoordinate)
                    } else {
                        ColorHexCell(color: item.color)
                            .id(item.offsetCoordinate)
                    }
                },
                overlay: { item in
                    if let overlay = overlay {
                        overlay(item)
                            .id("\(item.offsetCoordinate)_overlay")
                    } else {
                        EmptyView()
                    }
                }
            )
            .background { Color.appBackground }
            .transaction { transaction in
                // Disable animations during refresh to prevent jumping
                if viewModel.isRefreshing {
                    transaction.animation = nil
                }
            }
        }
        .background { Color.appBackground }
    }
}
