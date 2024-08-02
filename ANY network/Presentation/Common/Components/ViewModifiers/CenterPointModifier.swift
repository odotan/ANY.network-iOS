import SwiftUI

struct CenterPointPreferenceKey: PreferenceKey {
    typealias Value = CGPoint?
    static var defaultValue: Value = nil
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue() ?? value
    }
}

struct CenterPointModifier: ViewModifier {
    var callback: (CGPoint) -> Void
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .preference(key: CenterPointPreferenceKey.self, value: CGPoint(
                    x: geometry.frame(in: .global).midX,
                    y: geometry.frame(in: .global).midY
                ))
                .onPreferenceChange(CenterPointPreferenceKey.self) { value in
                    if let value = value {
                        callback(value)
                    }
                }
        }
    }
}

extension View {
    func captureCenterPoint(callback: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(CenterPointModifier(callback: callback))
    }
}
