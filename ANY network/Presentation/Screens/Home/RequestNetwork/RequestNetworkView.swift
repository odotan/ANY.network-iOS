import SwiftUI

struct RequestNetworkView: View {
    @Namespace private var animationNamespace
    @StateObject var viewModel: RequestNetworkViewModel
    
    let cellSize = CGSize(width: <->85, height: |96.42)

    var body: some View {
        ScrollableHexGrid(viewModel: viewModel.gridModel, content: { cell in
            AnyView(view(for: cell))
        })
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
        .background { Color.appBackground }
        .toolbar(.hidden)
        .ignoresSafeArea()
        .overlay {
            details()
        }
        .overlay(alignment: .leading) {
            LinearGradient(colors: [.appBackground, .clear], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 0))
                .frame(width: <->232)
                .offset(x: -116)
                .transition(.opacity.combined(with: .scale))
                .opacity((viewModel.state.selectedCell != nil) ? 1 : 0)
        }
        .overlay(alignment: .trailing) {
            LinearGradient(colors: [.appBackground, .clear], startPoint: .init(x: 1, y: 0), endPoint: .init(x: 0, y: 0))
                .frame(width: <->232)
                .offset(x: +116)
                .transition(.opacity.combined(with: .scale))
                .opacity((viewModel.state.selectedCell != nil) ? 1 : 0)
        }
        .overlay(alignment: .top) {
            VStack(spacing: 26) {
                Text("Request network")
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.3)
                    .lineLimit(2)
                    .font(.montserat(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: <->300)
                    .padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [.appBackground, .appBackground, .clear], startPoint: .top, endPoint: .bottom))
        }
        .backButton {
            if viewModel.state.selectedCell != nil {
                withAnimation {
                    viewModel.handle(.moveBack)
                }
            } else {
                viewModel.handle(.goBack)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.handle(.recenter)
            }
        }
    }
    
    @ViewBuilder
    private func view(for cell: HexCell) -> some View {
        if let network = NetworkItem.requestOrder[cell.priority!] {
            if let _ = viewModel.state.selectedCell {
                ColorHexCell(color: network.backgroundColor)
            } else {
                NetworkCell(animationNamespace: animationNamespace, zoomLevel: $viewModel.gridModel.gridZoomScale, item: network, size: cellSize) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        viewModel.handle(.select(cell))
                    }
                }
            }
        } else {
            ColorHexCell(color: cell.color)
        }
    }
    
    @ViewBuilder
    private func details() -> some View {
        if let selected = viewModel.state.selectedCell, let network = NetworkItem.requestOrder[selected.priority!] {
            VStack(spacing: 0) {
                Image(network.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->71, height: |71)
                    .padding(.bottom, |15)
                //                .matchedGeometryEffect(id: "\(network.imageName)-logo", in: animationNamespace) // Unique per item
                
                Text("Request For")
                    .font(.montserat(size: 14))
                    .padding(.bottom, |5)
                
                Text(network.title)
                    .font(.montserat(size: 24, weight: .bold))
                    .padding(.bottom, |17)
                
                Text("Request to view \(String(describing: viewModel.state.contact.givenName ?? ""))’s \(network.title).\nYou can add points to the request")
                    .font(.montserat(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, |30)
                
                Text("Add Points")
                    .font(.montserat(size: 16, weight: .semibold))
                    .padding(.bottom, |26)
                
                Picker("", selection: pointValue) {
                    ForEach(1..<100) {
                        Text("\($0)")
                            .font(.montserat(size: 30, weight: .bold))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 100)
                
                Button {
                    print("next")
                } label: {
                    Image(.arrowRight)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(24)
                }
                .padding(.top, |40)

            }
            .foregroundColor(.white)
            .transition(.opacity.combined(with: .scale))
            .opacity((viewModel.state.selectedCell != nil) ? 1 : 0)
        }
    }
    
    private var pointValue: Binding<Int> {
        .init(
            get: { viewModel.state.points },
            set: { viewModel.handle(.pointsUpdated($0)) }
        )
    }
}

#Preview {
    RequestNetworkView(viewModel: .init(contact: .testContact, coordinator: MainCoordinator()))
}
