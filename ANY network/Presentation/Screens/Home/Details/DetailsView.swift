import SwiftUI

struct DetailsView: View {
    @StateObject var viewModel: DetailsViewModel
    
    // Grid
    @State private var gridSize: CGSize = .zero
    @State private var gridZoomScale: CGFloat = 1
    @State private var gridContentOffset: CGPoint = .zero
    @State private var gridContainerSize: CGSize = .zero
    @State private var gridContentSize: CGSize = .zero
    
    @State var plusPosition: CGPoint = .zero
    @State var plusSize: CGSize = .zero

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
                switch (cell.offsetCoordinate.row, cell.offsetCoordinate.col) {
                case (4, 2):
                    AvatarHexCell(imageData: viewModel.state.contact.imageData, color: cell.color)
                case (5, 2):
                    if !viewModel.state.contact.phoneNumbers.isEmpty {
                        IconHexCell(type: .phone) {
                            print("Phone")
                        }
                    } else { cell.color }
                case (10, 1): // Plus icon
                    ColorHexCell(color: cell.color)
                        .sizeInfo(size: $plusSize)
                        .captureCenterPoint {
                            guard plusPosition == .zero else { return }
                            plusPosition = $0
                        }
                default:
                    ColorHexCell(color: cell.color)
                }
            }
            .background { Color.appBackground }
        }
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.clear, Color(hex: "120E1E")!], startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1))
                .frame(height: |145)
                .frame(maxWidth: .infinity)
        }
        .overlay {
            IconHexCell(type: .plus) { }
                .frame(width: plusSize.width, height: plusSize.height)
                .clipShape(HexagonShape(cornerRadius: 8))
                .position(plusPosition)
        }
        .background { Color.appBackground }
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Text(viewModel.state.contact.fullName)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.3)
                .lineLimit(2)
                .font(.montserat(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: <->300)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                viewModel.handle(.starPressed)
            } label: {
                Image(viewModel.state.isFavorite ? .startFillIcon : .starIcon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.horizontal, 8)
            }
            .padding(.trailing, 8)
        }
        .toolbar(.hidden)
        .backButton {
            viewModel.handle(.goBack)
        }
    }
}
//
//#Preview {
//    DetailsView(viewModel: .init(
//        contact: Contact(id: "", givenName: "John", familyName: "Dembow", imageData: nil, imageDataAvailable: false, isFavorite: false),
//        coordinator: MainCoordinator())
//    )
//}
