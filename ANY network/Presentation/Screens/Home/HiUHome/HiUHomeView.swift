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
            }
        )
        .simultaneousGesture(TapGesture().onEnded {
            handleTap(for: cell)
        })
    }
}
