import SwiftUI

struct SizeModifier: ViewModifier {
    @Binding var size: CGSize
    var shouldApply: (CGSize) -> Bool
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { reader in
                    Color.clear
                        .task(id: reader.size) {
                            if shouldApply(reader.size) {
                                size = reader.size
                            }
                        }
                }
            }
    }
}

extension View {
    func sizeInfo(size: Binding<CGSize>, shouldApply: @escaping (CGSize) -> Bool = { _ in true }) -> some View {
        modifier(SizeModifier(size: size, shouldApply: shouldApply))
    }
}
