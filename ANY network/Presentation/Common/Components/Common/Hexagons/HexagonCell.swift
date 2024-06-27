import SwiftUI

struct HexagonCell: View {
    private let action: () -> Void
    private let item: HexagonItem
    @Binding var isEnabled: Bool
        
    init(item: HexagonItem, isEnabled: Binding<Bool>, action: @escaping () -> Void) {
        self.item = item
        self.action = action
        self._isEnabled = isEnabled
    }
    
    var body: some View {
        GeometryReader { reader in
            Button(action: action, label: {
                item.color
                    .overlay(content: {
                        item.type.icon
                            .allowsHitTesting(false)
                            .frame(width: reader.size.width / 3, height: reader.size.height / 3)
                    })
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    .clipShape(HexagonShape(cornerRadius: 8))
                    .contentShape(HexagonShape(cornerRadius: 8))
                    .clipped()
                    .opacity(isEnabled ? 1.0 : item.opacity)
                    .id(item.type)
            })
            .animatedGlow(enabled: isEnabled, color: item.color)
            .disabled(!isEnabled)
        }
    }
}

#Preview {
    VStack {
        HexagonCell(item: .init(type: .contacts), isEnabled: .constant(true), action: {})
            .frame(width: 109.51, height: 123.39)

        HexagonCell(item: .init(type: .photo), isEnabled: .constant(false), action: {})
            .frame(width: 109.51, height: 123.39)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}
