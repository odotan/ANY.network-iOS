import SwiftUI

struct HexFlowerCell: View, HexCellProtocol {
    @Binding var model: HexFlowerModel
    @State var id: UUID = UUID()
    @State private var currentProgress: CGFloat = 0
    @State private var timer: Timer?
    var color: Color

    var stateChanged: (HexFlowerState) -> Void
    var details: () -> Void

    private func updateProgress() {
        guard let startedAt = model.startedAt else {
            currentProgress = 0
            return
        }
        
        let seconds = floor(Date.now.timeIntervalSince(startedAt))
        
        // First minute: one point per second
        if seconds <= 60 {
            currentProgress = CGFloat(seconds)
        }
        // 1-60 minutes: one point per minute
        else if seconds <= 3600 {
            currentProgress = CGFloat(60 + (seconds / 60 - 1))
        }
        // 1-24 hours: one point per hour
        else if seconds <= 86400 {
            currentProgress = CGFloat(120 + (seconds / 3600 - 1))
        }
        else {
            currentProgress = 144
        }
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
                ClockCircleView(progress: $currentProgress, startDate: model.startedAt ?? Date())
                    .scaleEffect(1.2)

                Text("\(Int(currentProgress))")
                    .font(Font.montserat(size: 20, weight: .bold))
                    .minimumScaleFactor(0.3)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .contentTransition(.numericText(value: Double(currentProgress)))
                    .animation(.easeInOut, value: model.seconds)
            }
        }
        .onAppear {
            if model.state == .timerStarted {
                startTimer()
            }
        }
        .onChange(of: model.state) { oldState, newState in
            if newState == .timerStarted {
                updateProgress()
                startTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .onTapGesture(count: 2, perform: doubleTap)
        .onTapGesture(count: 1, perform: singleTap)
        .onLongPressGesture(minimumDuration: 0.5, perform: longPress)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateProgress()
        }
    }

    private func singleTap() {
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

