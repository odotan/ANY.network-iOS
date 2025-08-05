import SwiftUI

struct HiUHomeView: View {
    @StateObject var viewModel: HiUHomeViewModel
    
    private var lastTapTime: Date? {
        viewModel.state.lastTapTime
    }
    
    private var lastTappedCell: HexCell? {
        viewModel.state.lastTappedCell
    }
    
    var body: some View {
         ScrollableHexGrid(viewModel: viewModel.gridModel, content: { cell in
             AnyView(view(for: cell))
         })
         .overlay(alignment: .top) {
             DynamicIslandView(coordinator: viewModel.flyingPointsCoordinator)
         }
         .overlay {
             FlyingPointsOverlay(coordinator: viewModel.flyingPointsCoordinator)
         }
         .edgesIgnoringSafeArea(.all)
         .onAppear {
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 viewModel.handle(.recenter)
             }
             
             // Initialize XMTP client when view appears
             viewModel.handle(.initializeXMTP)
         }
         .onDisappear {
            viewModel.handle(.stopStreams)
         }
    }
    
    private func handleTap(for cell: HexCell) {
        let now = Date()
        defer { 
            viewModel.handle(.updateLastTap(time: now, cell: cell))
        }
        
        guard let lastTime = lastTapTime,
              let lastCell = lastTappedCell,
              lastCell.offsetCoordinate == cell.offsetCoordinate,
              now.timeIntervalSince(lastTime) < 0.3 else {
            return
        }
        
        // Double tap detected
        if viewModel.state.selectedCell != nil {
            viewModel.handle(.moveBack)
        } else {
            viewModel.handle(.details(cell))
        }
    }
    
    @ViewBuilder
    private func view(for cell: HexCell) -> some View {
        let model = viewModel.state.cellQueue[cell.offsetCoordinate]
        let modelBinding: Binding<HexFlowerModel> = {
            model != nil ? Binding(
                get: { model! },
                set: { newValue in
                    viewModel.handle(.setCellState(cell.offsetCoordinate, newValue))
                }) : .constant(.init(user: .init(address: "", inboxId: "")))
        }()
        
        HexFlowerCell(
            model: modelBinding,
            color: cell.color,
            stateChanged: { state in
                viewModel.handle(.stateUpdated(state, cell))
            },
            details: {
                viewModel.handle(.details(cell))
            },
            onPointsEarned: { points, _ in
                // Calculate the position of the hexagon cell in the screen
                // For now, we'll use a simple approach - trigger the animation
                // The actual position calculation would need to be done with GeometryReader
                triggerFlyingPointsAnimation(points: points, from: cell.offsetCoordinate)
            }
        )
        .simultaneousGesture(TapGesture().onEnded {
            handleTap(for: cell)
        })
    }
    
    private func triggerFlyingPointsAnimation(points: Int, from coordinate: OffsetCoordinate) {
        // Calculate the approximate position of the hexagon cell
        // This is a simplified calculation - in a real app you'd want to use GeometryReader
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let startX = screenWidth / 2 + CGFloat(coordinate.col) * 50
        let startY = screenHeight / 2 + CGFloat(coordinate.row) * 60
        
        let startPosition = CGPoint(x: startX, y: startY)
        let endPosition = CGPoint(x: screenWidth / 2, y: 100) // Dynamic Island position
        
        viewModel.flyingPointsCoordinator.triggerFlyingPoints(points: points, from: startPosition, to: endPosition)
    }
}
