import SwiftUI

struct HexagonBackground<OverlayView: View>: View {
    private let spacing: CGFloat = 5.6
    private let cols: Int = 6
    private var width: CGFloat = 79.93
    private var height: CGFloat = 90.0
    
    private var icon: (() -> OverlayView)
    private var action: (() -> Void)?
    
    init(@ViewBuilder icon: @escaping (() -> OverlayView), action: (() -> Void)? = nil) {
        self.icon = icon
        self.action = action
    }

    @State private var scale: CGFloat = 1//.38

    var body: some View {
        let gridItems = Array(
            repeating: GridItem(.fixed(<->width), spacing: <->spacing),
            count: cols
        )
        
        HStack {
            LazyVGrid(columns: gridItems, spacing: |spacing) {
                ForEach(0..<backgroundHexagonItemsList.count, id:\.self) { idx in
                    HexagonCell(
                        item: backgroundHexagonItemsList[idx],
                        isEnabled: .constant(backgroundHexagonItemsList[idx].type == .action && action != nil),
                        action: action ?? {}
                    )
                    .frame(width: <->width, height: |height)
                    .offset(x: !isEvenRow(idx) ? 0 : <->width / 2 + (<->spacing/2))
                    .overlay(content: {
                        if backgroundHexagonItemsList[idx].type == .action {
                            icon()
                                .frame(width: <->10.52, height: |21.64)
                                .allowsHitTesting(false)
                                .offset(x: !isEvenRow(idx) ? 0 : <->width / 2 + (<->spacing/2))
                        }
                    })
                }
                .frame(width: <->width, height: |height * 0.75)
            }
        }
        .offset(y: |height / -2)
        .background(Color.appBackground.edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.all)
    }
    
    func isEvenRow(_ idx: Int) -> Bool { (idx / cols) % 2 == 0 }
}

#Preview {
    HexagonBackground(icon: {
        Image(systemName: "arrow.forward")
            .resizable()
            .foregroundColor(.white)
            .scaledToFit()
    }, action: {})
}
