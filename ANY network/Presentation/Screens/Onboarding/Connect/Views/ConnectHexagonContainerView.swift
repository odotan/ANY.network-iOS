import SwiftUI

struct ConnectHexagonContainerView: View {
    @State private var focusHegaxonType: HexagonType
    @Binding var isFocusItemVerified: Bool
    private let focusPressed: () -> Void

    init(focusHegaxonType: HexagonType, isFocusItemVerified: Binding<Bool>, focusPressed: @escaping () -> Void, selected: HexagonType? = nil) {
        self.focusHegaxonType = focusHegaxonType
        _isFocusItemVerified = isFocusItemVerified
        self.focusPressed = focusPressed
    }
    
    private let screenWidth: CGFloat = UIScreen.current!.bounds.size.width
    private var spacing: CGFloat { 7.7 }
    private let cols: Int = 5
    private var width: CGFloat {
        72.78// (screenWidth - CGFloat(self.spacing * CGFloat((self.cols - 1)))) / CGFloat(self.cols - 1)
    }
    private var height: CGFloat { 81.95 }//tan(Angle(degrees: 30).radians) * width * 2 }
    private var numberOfCells: Int {
        return 12 * cols
    }
    
    @State private var selected: HexagonType?
    @State private var scale: CGFloat = 1

    var body: some View {
        let gridItems = Array(repeating: GridItem(.fixed(width), spacing: spacing), count: cols)
        
        ScrollView([.horizontal, .vertical]) {
            ScrollViewReader { proxy in
                LazyVGrid(columns: gridItems, spacing: spacing) {
                    ForEach(0..<defaultHexagonItemsList.count, id:\.self) { idx in
                        HexagonCell(
                            item: defaultHexagonItemsList[idx],
                            isEnabled: Binding<Bool>(get: { focusHegaxonType == defaultHexagonItemsList[idx].type }, set: { _ in }),
                            action: focusPressed
                        )
                        .frame(width: width, height: height)
                        .offset(x: !isEvenRow(idx) ? 0 : width / 2 + (spacing/2))
                        .frame(width: width, height: height * 0.75)
                    }
                }
                .scaleEffect(scale, anchor: UnitPoint(
                    x: 0.35,
                    y: 0.58
                ))
                .frame(
                    width: UIScreen.current!.bounds.width,
                    height: UIScreen.current!.bounds.height
                )
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                        withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                            scale = 2.8
                        }
                    }
                })
            }
        }
        .scrollDisabled(true)
        .background(Color.appBackground)
        .edgesIgnoringSafeArea(.all)
    }
    
    func calculateUnitPoint() -> UnitPoint {
        print("Position", position)
        print("ScreenSize", UIScreen.current!.bounds)
        let point = UnitPoint(
            x: (UIScreen.current!.bounds.width * 2.8) * 2 / 5,
            y: (UIScreen.current!.bounds.height * 2.8 * 1 / 2)
        )
        return point
    }
    
    func isEvenRow(_ idx: Int) -> Bool { (idx / cols) % 2 == 0 }
}

#Preview {
    ConnectHexagonContainerView(focusHegaxonType: .contacts, isFocusItemVerified: .constant(true), focusPressed: {}, selected: .contacts)
}

extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}


extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
