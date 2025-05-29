import SwiftUI

struct HexFlowerCell: View, HexCellProtocol {
    @Binding var model: HexFlowerModel
    @State var id: UUID = UUID()
    @State private var currentProgress: CGFloat = 0
    var color: Color

    var stateChanged: (HexFlowerState) -> Void
    var details: () -> Void

    var points: String {
        guard let startedAt = model.startedAt else { return "0" }
        let seconds = Int(Date.now.timeIntervalSince(startedAt))
        
        // First minute: 1 point per second (0-60 points)
        if seconds <= 60 {
            return "\(seconds)"
        }
        
        // 1-60 minutes: 1 point per minute (61-120 points)
        let minutes = seconds / 60 - 1
        if minutes <= 60 {
            return "\(60 + minutes)"
        }
        
        // 1-24 hours: 1 point per hour (121-144 points)
        let hours = seconds / 3600 - 1
        if hours <= 24 {
            return "\(120 + hours)"
        }
        
        return "144" // Max points
    }

    var circleProgress: CGFloat {
        guard let startedAt: Date = model.startedAt else { return 0 }
        let seconds = Int(Date.now.timeIntervalSince(startedAt))
        
        // First minute: one point per second
        if seconds <= 60 {
            return CGFloat(seconds)
        }
        
        // 1-60 minutes: one point per minute
        let minutes = seconds / 60 - 1
        if minutes <= 60 {
            return CGFloat(60 + minutes)
        }
        
        // 1-24 hours: one point per hour
        let hours = seconds / 3600 - 1
        if hours <= 24 {
            return CGFloat(120 + hours)
        }
        
        return 144
    }

    var body: some View {
        ZStack {
            color
            
            Color.white
                .opacity(model.state == .initial ? 0 : 0.1)
                .animation(.easeInOut(duration: 0.3), value: model.state)
            
            Color.red.opacity(model.state == .timerStarted ? 0.8 : 0)
                .animation(.easeInOut(duration: 0.3), value: model.state)
            
            switch model.state {
            case .initial:
                EmptyView()
            case .selected:
                EmptyView()
            case .animationStarted:
                Flower {
                    model.state = .timerStarted
                    stateChanged(.timerStarted)
                }
            case .timerStarted:
                ClockCircleView(progress: $currentProgress)
                    .scaleEffect(1.2)
                    .onChange(of: circleProgress) { _, newValue in
                        currentProgress = newValue
                    }

                Text(points)
                    .font(Font.montserat(size: 20, weight: .bold))
                    .minimumScaleFactor(0.3)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .contentTransition(.numericText(value: Double(points) ?? 0))
                    .animation(.easeInOut, value: model.seconds)
            }
        }
        .onTapGesture(count: 2, perform: doubleTap)
        .onTapGesture(count: 1, perform: singleTap)
        .onLongPressGesture(minimumDuration: 0.5, perform: longPress)
        .onChange(of: model.state) { oldState, newState in
            print("HexFlowerCell: State changed from \(oldState) to \(newState)")
        }
    }

    private func singleTap() {
        model.startedAt = Date.now
        model.state = .selected
        stateChanged(.selected)
    }
    
    private func doubleTap() {
        details()
    }
    
    private func longPress() {
        details()
    }
}

#Preview {
    HexFlowerCell(
        model: .constant(.init()),
        color: Color.gray,
        stateChanged: { _ in
        },
        details: {})
        .frame(width: 79.74 * 2.0, height: 90.46 * 2.0)
        .clipShape(HexagonShape(cornerRadius: 4))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

