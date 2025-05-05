import SwiftUI

struct PillToolbarItem: Identifiable {
    internal var id: UUID = UUID()
    
    let icon: PillToolbarIcon
    let position: PillToolbarPosition
    let action: () -> Void
}

struct PillToolbarItemView: View {
    let icon: PillToolbarIcon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if let iconName = icon.imageName {
                Image(iconName)
                    .resizable()
                    .frame(width: icon.iconSize.width, height: icon.iconSize.height)
            } else if case .customText(let string) = icon {
                Text(string)
                    .font(.montserat(size: 16, weight: .regular))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    HStack {
        PillToolbarItemView(icon: .add) {}
        PillToolbarItemView(icon: .back) {}
        PillToolbarItemView(icon: .favorite) {}
        PillToolbarItemView(icon: .message) {}
        PillToolbarItemView(icon: .search) {}
    }
    .background(.appBackground)
}
