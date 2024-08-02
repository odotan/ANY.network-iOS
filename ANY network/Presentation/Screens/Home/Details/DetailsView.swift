import SwiftUI

struct DetailsView: View {
    @StateObject var viewModel: DetailsViewModel
    
    // Grid
    @State private var gridSize: CGSize = .zero
    @State private var gridZoomScale: CGFloat = 1
    @State private var gridContentOffset: CGPoint = .zero
    @State private var gridContainerSize: CGSize = .zero
    @State private var gridContentSize: CGSize = .zero

    var body: some View {
        let cellSize = CGSize(width: <->79.93, height: |89.99)
        
        ScrollViewWrapper(
            contentOffset: $gridContentOffset,
            contentSize: $gridContentSize,
            size: $gridContainerSize,
            zoomScale: $gridZoomScale,
            animationDuration: 0.35
        ) {
            HexGrid(HexCell.all, spacing: 8, cornerRadius: 6, fixedCellSize: cellSize) { cell in
                switch (cell.offsetCoordinate.row, cell.offsetCoordinate.col) {
                case (4, 2):
                    cell.color
                        .overlay {
                            if let data = viewModel.contact.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                cell.color
                                    .overlay {
                                        Image(.avatar)
                                            .resizable()
                                            .frame(width: <->26.37, height: |30.7)
                                    }
                            }
                        }
                default:
                    cell.color
                }
            }
            .background { Color.appBackground }
        }
        .background { Color.appBackground }
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Text(viewModel.contact.fullName)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.3)
                .lineLimit(2)
                .font(.montserat(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: <->300)
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
