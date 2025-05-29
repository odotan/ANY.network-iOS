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
    let startDate: Date
    @State private var animationProgress: Double = 0
    @State private var timer: Timer?
    
    private func calculateAnimationProgress() -> Double {
        let now = Date.now.timeIntervalSince1970
        let start = startDate.timeIntervalSince1970
        let elapsed = now - start
        
        let progress: Double
        if elapsed <= 60 {
            // Seconds: Complete circle every second
            progress = elapsed
        } else if elapsed < 3660 {
            // Minutes: Complete circle every minute
            progress = elapsed / 60.0
        } else {
            // Hours: Complete circle every hour
            progress = elapsed / 3600.0
        }
        
        // Ensure we never exceed 1.0 and handle the transition smoothly
        if progress >= 1.0 {
            print(progress - floor(progress))
            return progress - floor(progress)
        }

        return progress
    }
    
    var body: some View {
        PieSliceShape(
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + animationProgress * 360)
        )
        .fill(Color.appGray.opacity(0.3))
        .onAppear {
            startNewAnimation()
        }
        .onChange(of: progress) { old, new in
            startNewAnimation()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startNewAnimation() {
        timer?.invalidate()
        timer = nil
        
        let interval: TimeInterval
        if progress >= 120 {
            // After 120 points, update every minute
            interval = 1.0
        } else if progress > 60 {
            // After 60 points, update every second
            interval = 1.0
        } else {
            // First 60 points, update frequently for smooth animation
            interval = 1.0/60.0
        }
        
        // Initial update
        animationProgress = calculateAnimationProgress()
        print(interval, progress)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            withAnimation(.linear(duration: interval)) {
                animationProgress = calculateAnimationProgress()
            }
        }
    }
}

#Preview {
    ClockCircleView(progress: .constant(0.5), startDate: Date())
}
