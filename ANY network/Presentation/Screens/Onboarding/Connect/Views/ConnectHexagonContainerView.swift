import SwiftUI

struct ConnectHexagonContainerView: View {
    struct Item: Hashable {
        var color: Color
        var count: Int
    }

    private let focusHegaxonType: ConnectType
    @Binding var isFocusItemVerified: Bool
    private let focusPressed: () -> Void

    init(focusHegaxonType: ConnectType, isFocusItemVerified: Binding<Bool>, focusPressed: @escaping () -> Void, selected: ConnectType? = nil) {
        self.focusHegaxonType = focusHegaxonType
        _isFocusItemVerified = isFocusItemVerified
        self.focusPressed = focusPressed
    }
    
    private let screenWidth: CGFloat = UIScreen.current!.bounds.size.width
    private let spacing: CGFloat = 8
    private let cols: Int = 4
    private var width: CGFloat {
        (screenWidth - CGFloat(self.spacing * CGFloat((self.cols - 1)))) / CGFloat(self.cols - 1)
    }
    private var height: CGFloat { tan(Angle(degrees: 30).radians) * width * 2 }
    private var numberOfCells: Int {
        var rows = Int((UIScreen.current!.bounds.size.height / height) * 1.33)
        rows = rows % 2 == 0 ? rows + 1 : rows
        return rows * cols
    }
    
    @State private var selected: ConnectType?
    @State private var scale: CGFloat = 1.0
    
    @State private var scrollToId: UUID?
    
    var body: some View {
        let gridItems = Array(repeating: GridItem(.fixed(width), spacing: spacing), count: cols)
        
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical]) {
                LazyVGrid(columns: gridItems, spacing: spacing) {
                    ForEach(0..<numberOfCells, id: \.self) { idx in
                        VStack(spacing: 0) {
                            ConnectHexagonView(action: {
                                focusPressed()
                            }, idx: idx, count: numberOfCells, typeEnabled: focusHegaxonType)
                            .frame(width: width, height: height)
                            .offset(x: isEvenRow(idx) ? 0 : width / 2 + (spacing/2))
                        }
                        .frame(width: width, height: height * 0.75)
                    }
                }
                .frame(width: UIScreen.current!.bounds.width, height: UIScreen.current!.bounds.height)
                .scaleEffect(scale)
            }
            
            .background(Color.clear)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    withAnimation(.easeOut) {
                        scale = 1.7
                        proxy.scrollTo(focusHegaxonType, anchor: .center)
                    }
                }
            }
            
        }
    }
    
    func isEvenRow(_ idx: Int) -> Bool { (idx / cols) % 2 == 0 }
}

struct ContentTestView: View {
    @State private var scale: CGFloat = 1.0
    @State private var scrollToId: Int? = nil

    var body: some View {
        ScrollViewReader { proxy in
                    GeometryReader { reader in
                        ScrollView {
                            VStack {
                                ForEach(0..<100, id: \.self) { index in
                                    Text("Item \(index)")
                                        .padding()
                                        .background(index == 50 ? Color.red : Color.clear)
                                        .id(index)
                                }
                            }
//                            .frame(width: reader.size.width, height: reader.size.height * scale)
                            .scaleEffect(scale)
                        }
                        .onAppear {
                            withAnimation {
                                scale = 1.7
                                proxy.scrollTo(78, anchor: .center)
                            }
                        }
                    }
                }
    }
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
