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
        Button {
            model.state = .selected
            stateChanged(.selected)
        } label: {
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
                        withAnimation(.easeInOut(duration: 0.3)) {
                            model.state = .timerStarted
                            stateChanged(.timerStarted)
                        }
                    }
                case .timerStarted:
                    ClockCircleView(progress: $currentProgress, startDate: model.startedAt ?? Date())
                        .scaleEffect(1.2)

                    TimerNumberView(number: Int(currentProgress))
                        .font(Font.montserat(size: 24, weight: .semibold))
                        .minimumScaleFactor(0.3)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .monospacedDigit()
                        .transaction { transaction in
                            transaction.animation = .spring(
                                response: 0.4,
                                dampingFraction: 0.65,
                                blendDuration: 0.5
                            )
                        }
                        .id(Int(currentProgress))
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom)
                                    .combined(with: .opacity)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0.5)),
                                removal: .move(edge: .top)
                                    .combined(with: .opacity)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3))
                            )
                        )
                }
            }
        }
        .disabled(model.state != .initial)
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
        .onLongPressGesture(minimumDuration: 0.5, perform: longPress)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateProgress()
        }
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

