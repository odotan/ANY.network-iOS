import SwiftUI

struct NetworkLogoHexView: View {
    let item: NetworkItem
    var isConfirmation: Bool = false
    private let cellSize = CGSize(width: <->80.51, height: |91.13)

    var body: some View {
        item.backgroundColor
            .overlay {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->42, height: |42)
            }
            .frame(width: cellSize.width, height: cellSize.height)
            .clipShape(HexagonShape(cornerRadius: 3))
            .overlay(alignment: .topTrailing) {
                if isConfirmation {
                    Color.white
                        .frame(width: <->32, height: |32)
                        .clipShape(Circle())
                        .overlay {
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .fontWeight(.bold)
                                .padding(.horizontal, <->9.7)
                                .foregroundColor(item.backgroundColor)
                        }
                        .offset(x: <->16, y: |5)
                } else {
                    EmptyView()
                }
            }
    }
}

#Preview {
    VStack {
        NetworkLogoHexView(item: .facebook, isConfirmation: true)
        NetworkLogoHexView(item: .instagram)
        NetworkLogoHexView(item: .phone)
        NetworkLogoHexView(item: .contacts)
        NetworkLogoHexView(item: .bitcoin)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appBackground)
}
