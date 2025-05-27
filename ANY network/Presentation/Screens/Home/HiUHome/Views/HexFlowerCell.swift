import SwiftUI

struct HexFlowerCell: View, HexCellProtocol {
    @Binding var model: HexFlowerModel
    @State var id: UUID = UUID()
    var color: Color

    var stateChanged: (HexFlowerState) -> Void
    var details: () -> Void
        
    var body: some View {
        ZStack {
            color
            
            Color.white
                .opacity(model.state == .initial || model.state == .selected ? 0 : 0.1)
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
                Text(seconds)
                    .font(Font.montserat(size: 20, weight: .bold))
                    .minimumScaleFactor(0.3)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .contentTransition(.numericText(value: Double(model.seconds)))
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
    
    var seconds: String {
        guard let startedAt = model.startedAt else { return "0" }
        let seconds = Int(Date.now.timeIntervalSince(startedAt))
        return "\(seconds)"
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

