import SwiftUI

struct ConnectView: View {
    @Namespace private var animationNamespace

    @StateObject var viewModel: ConnectViewModel
    
    let cellSize = CGSize(width: <->85, height: |96.42)

    var body: some View {
        ScrollableHexGrid(viewModel: viewModel.gridModel, content: { cell in
            AnyView(view(for: cell, cellSize: cellSize))
        })
        .background { Color.appBackground }
        .toolbar(.hidden)
        .ignoresSafeArea()
        .backButton {
            viewModel.handle(.goBack)
        }
        .overlay(alignment: .top) {
            VStack(spacing: 26) {
                Text("Connect")
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.3)
                    .lineLimit(2)
                    .font(.montserat(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: <->300)
                
                Text("Sign in or sign up with any network below")
                    .font(.montserat(size: 12, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7))
            }
            .background(LinearGradient(colors: [.appBackground, .appBackground, .clear], startPoint: .top, endPoint: .bottom))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.handle(.recenter)
            }
        }
    }

    @ViewBuilder
    private func view(for cell: HexCell, cellSize: CGSize) -> some View {
        if let network = NetworkItem.connectOrder[cell.priority!] {
            if network == NetworkItem.words {
                NetworkCell(animationNamespace: animationNamespace, zoomLevel: $viewModel.gridModel.gridZoomScale, item: .words, wordsCount: 12, size: cellSize) {
                    viewModel.handle(.networkSelected(.words))
                }
                .disabled(true)
                .opacity(0.5)
            } else {
                NetworkCell(animationNamespace: animationNamespace, zoomLevel: $viewModel.gridModel.gridZoomScale, item: network, size: cellSize) {
                    viewModel.handle(.networkSelected(network))
                }
                .disabled(!viewModel.checkIfAvailable(network: network))
                .opacity(viewModel.checkIfAvailable(network: network) ? 1 : 0.5)
            }
        } else {
            ColorHexCell(color: cell.color)
        }
    }
}
