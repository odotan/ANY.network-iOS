import SwiftUI

struct GlowModifier: ViewModifier {
    @State private var animate: Bool = false
    var enabled: Bool
    var color: Color

    func body(content: Content) -> some View {
        if enabled {
            content
                .shadow(color: color.opacity(animate ? 0.9 : 0.3),
                        radius: animate ? 10 : 5,
                        x: 0, y: 0)
                .onAppear {
                    withAnimation(Animation.easeInOut.repeatForever(autoreverses: true)) {
                        animate.toggle()
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func animatedGlow(enabled: Bool, color: Color) -> some View {
        modifier(GlowModifier(enabled: enabled, color: color))
    }
}

#Preview {
    Color.blue
        .frame(width: 100, height: 100)
        .animatedGlow(enabled: true, color: .blue)
}
