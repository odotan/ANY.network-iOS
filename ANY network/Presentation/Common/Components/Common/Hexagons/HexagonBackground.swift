import SwiftUI

struct HexagonBackground<OverlayView: View>: View {
    private let screenWidth: CGFloat = UIScreen.current!.bounds.size.width
    private let spacing: CGFloat = 5.6
    private let cols: Int = 7
    private var width: CGFloat {
        57.86//(screenWidth - CGFloat(self.spacing * CGFloat((self.cols - 1)))) / CGFloat(self.cols - 1)
    }
    private var height: CGFloat { 65.14 }//tan(Angle(degrees: 30).radians) * width * 2 }
    
    private var icon: (() -> OverlayView)
    private var action: (() -> Void)?
    
    init(icon: @escaping (() -> OverlayView), action: (() -> Void)? = nil) {
        self.icon = icon
        self.action = action
    }

    @State private var scale: CGFloat = 1.38

    var body: some View {
        hexagons()
//            .overlay {
//                actionButtonGrid()
//                    .edgesIgnoringSafeArea(.all)
//            }
            .scaleEffect(scale)
            .background(Color.appBackground.edgesIgnoringSafeArea(.all))
            .edgesIgnoringSafeArea(.all)
    }
    
    func isEvenRow(_ idx: Int) -> Bool { (idx / cols) % 2 == 0 }
    
    @ViewBuilder
    func hexagons() -> some View {
        let gridItems = Array(
            repeating: GridItem(.fixed(width), spacing: spacing),
            count: cols
        )
        
        GeometryReader { reader in
            LazyVGrid(columns: gridItems, spacing: spacing) {
                ForEach(0..<backgroundHexagonItemsList.count, id:\.self) { idx in
                    HexagonCell(
                        item: backgroundHexagonItemsList[idx],
                        isEnabled: .constant(backgroundHexagonItemsList[idx].type == .action && action != nil),
                        action: action ?? {}
                    )
                    .frame(width: width, height: height)
                    .offset(x: isEvenRow(idx) ? 0 : width / 2 + (spacing/2))
                    .overlay(content: {
                        if backgroundHexagonItemsList[idx].type == .action {
                            icon()
                                .frame(width: 10.52, height: 21.64)
                                .allowsHitTesting(false)
                                .offset(x: isEvenRow(idx) ? 0 : width / 2 + (spacing/2))
                        }
                    })
                }
                .frame(width: width, height: height * 0.75)
            }
            .frame(width: reader.size.width, height: reader.size.height)
        }
    }
    
    @ViewBuilder
    func actionButtonGrid() -> some View {
        let gridItems = Array(repeating: GridItem(.fixed(width), spacing: spacing), count: cols)

        GeometryReader { reader in
            LazyVGrid(columns: gridItems, spacing: spacing) {
                ForEach(0..<backgroundHexagonItemsList.count, id:\.self) { idx in
                    VStack(spacing: 0) {
                        GeometryReader { reader in
                            VStack {
                                if backgroundHexagonItemsList[idx].type == .action {
                                    HexagonCell(
                                        item: backgroundHexagonItemsList[idx],
                                        isEnabled: .constant(true),
                                        action: action ?? {}
                                    )
                                } else {
                                    EmptyView()
                                }
                            }
                            .frame(width: width, height: height)
                            .offset(x: isEvenRow(idx) ? 0 : width / 2 + (spacing/2))
                            .overlay(content: {
                                if backgroundHexagonItemsList[idx].type == .action {
                                    icon()
                                        .frame(width: reader.size.width / 2)
                                        .allowsHitTesting(false)
                                        .offset(x: isEvenRow(idx) ? 0 : width / 2 + (spacing/2))
                                }
                            })
                        }
                    }
                    .frame(width: width, height: height * 0.75)
                }
            }
            .frame(width: reader.size.width, height: reader.size.height)
        }
    }
}

#Preview {
    HexagonBackground(icon: {
        Image(systemName: "arrow.forward")
            .resizable()
            .foregroundColor(.white)
            .scaledToFit()
    }, action: {})
}
