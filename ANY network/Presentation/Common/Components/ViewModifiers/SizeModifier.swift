import SwiftUI

public extension View {
    func onSizeChange(ignoreSafeArea: Bool = false, round: Bool = false, perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(SizeChangeModifier(
            ignoreSafeArea: ignoreSafeArea,
            round: round,
            onSizeChange: action
        ))
    }
}

private struct SizeChangeModifier: ViewModifier {
    var ignoreSafeArea: Bool
    var round: Bool
    var onSizeChange: (CGSize) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(key: SizePreferenceKey.self, value: size(from: geometry))
                        .onPreferenceChange(SizePreferenceKey.self, perform: onSizeChange)
                }
            )
    }
    
    func size(from proxy: GeometryProxy) -> CGSize {
        var size = proxy.size
        if ignoreSafeArea {
            size.width += proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
            size.height += proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
        }
        if round {
            size.width = size.width.rounded()
            size.height = size.height.rounded()
        }
        return size
    }
    
    struct SizePreferenceKey: PreferenceKey {
        static var defaultValue: CGSize = .zero
        
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
}
