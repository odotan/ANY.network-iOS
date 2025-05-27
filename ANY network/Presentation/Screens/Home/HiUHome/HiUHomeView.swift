import SwiftUI

struct HiUHomeView: View {
    @StateObject var viewModel: HiUHomeViewModel
    
    var body: some View {
         ScrollableHexGrid(viewModel: viewModel.gridModel, content: { cell in
             AnyView(view(for: cell))
         })
         .edgesIgnoringSafeArea(.all)
         .onAppear {
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 viewModel.handle(.recenter)
             }
         }
    }
    
    @ViewBuilder
    private func view(for cell: HexCell) -> some View {
        let model = viewModel.state.cellQueue[cell.offsetCoordinate]
        if var model = model {
            HexFlowerCell(
                model: Binding(
                    get: { model },
                    set: { newValue in
                        viewModel.updateCellState(at: cell.offsetCoordinate, with: newValue)
                    }
                ),
                color: cell.color,
                stateChanged: { state in
                    viewModel.handle(.stateUpdated(state, cell))
                },
                details: { 
                    viewModel.handle(.doubleTap(cell)) 
                }
            )
        } else {
            HexFlowerCell(
                model: .constant(.init()),
                color: cell.color,
                stateChanged: { state in
                    viewModel.handle(.stateUpdated(state, cell))
                },
                details: { 
                    viewModel.handle(.doubleTap(cell)) 
                }
            )
        }
    }
}
