import SwiftUI

struct IntroView: View {
    @StateObject var viewModel: IntroViewModel

    private let all = HexCell.all

    var body: some View {
        HexGrid(all, spacing: 8, cornerRadius: 6, fixedCellSize: nil) { cell in
            cell.color
        }
        .onTapGesture {
            viewModel.handle(.next)
        }
        .frame(width: <->518.08, height: |999.99)
        .background(Color.appBackground)
    }
}

#Preview {
    IntroView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {})))
}
