import SwiftUI

struct HexagonSwapAnimationOverlay<HexView: View>: View {
    let swapeePos: CGPoint
    let swaperPos: CGPoint
    @State private var shouldMove: Bool = false
    let hexagonToMove: () -> HexView
    
    init(swapeePos: CGPoint, swaperPos: CGPoint, @ViewBuilder hexagonToMove: @escaping () -> HexView) {
        self.swapeePos = swapeePos
        self.swaperPos = swaperPos
        self.hexagonToMove = hexagonToMove
    }
    
    var body: some View {
        ZStack {
            hexagonToMove()
                .position(swapeePos)
                .offset(calculateOffset())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    shouldMove = true
                }
            }
        }
        .background(.clear)
        .allowsHitTesting(false)
    }
    
    private func calculateOffset() -> CGSize {
        if shouldMove {
            let offset: CGSize = .init(
                width: swapeePos.x.distance(to: swaperPos.x),
                height: swapeePos.y.distance(to: swaperPos.y)
            )
            return offset
        } else {
            return .zero
        }
    }
}

#Preview {
    HexagonSwapAnimationOverlay(
        swapeePos: .init(x: 140, y: 140),
        swaperPos: .init(x: 320, y: 320),
        hexagonToMove: {
            AvatarHexCell(contact: .testContact)
        }
    )
}
