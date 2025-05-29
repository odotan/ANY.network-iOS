import SwiftUI

struct PieSliceShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

struct ClockCircleView: View {
    @Binding var progress: CGFloat
    @State private var animationProgress: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Background segments (6 x 60 degrees)
            ForEach(0..<6) { segment in
                PieSliceShape(
                    startAngle: .degrees(Double(segment) * 60 - 90),
                    endAngle: .degrees(Double(segment + 1) * 60 - 90)
                )
                .stroke(Color.appGray.opacity(0.1), lineWidth: 1)
            }
            
            // Filled progress pie slice
            PieSliceShape(
                startAngle: .degrees(-90),
                endAngle: .degrees(-90 + animationProgress * 360)
            )
            .fill(Color.appGray.opacity(0.3))
        }
        .onChange(of: progress) { _, _ in
            startNewAnimation()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startNewAnimation() {
        // Stop existing timer if any
        timer?.invalidate()
        timer = nil
        
        print("startNewAnimation")
        // Reset progress
        animationProgress = 0
        
        // Start new timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            if animationProgress >= 1.0 {
                timer.invalidate()
                return
            }
            
            withAnimation(.linear(duration: 0.016)) {
                animationProgress += 0.016
            }
        }
    }
}

#Preview {
    ClockCircleView(progress: .constant(0.5))
}
