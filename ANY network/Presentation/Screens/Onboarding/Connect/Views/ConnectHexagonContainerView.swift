//import SwiftUI
//
//struct ConnectHexagonContainerView: View {
//    @State private var focusHegaxonType: HexagonType?
//    @Binding var isFocusItemVerified: Bool
//    private let focusPressed: () -> Void
//
//    init(focusHegaxonType: HexagonType? = nil, isFocusItemVerified: Binding<Bool>, focusPressed: @escaping () -> Void, selected: HexagonType? = nil) {
//        self.focusHegaxonType = focusHegaxonType
//        _isFocusItemVerified = isFocusItemVerified
//        self.focusPressed = focusPressed
//    }
//    
//    private var spacing: CGFloat = 7.7
//    private let cols: Int = 5
//    private var width: CGFloat = 72.78
//    private var height: CGFloat = 81.95
//    private var numberOfCells: Int {
//        return 12 * cols
//    }
//    
//    @State private var selected: HexagonType?
//    @State private var scale: CGFloat = 1.1
//
//    var body: some View {
//        let gridItems = Array(repeating: GridItem(.fixed(<->width), spacing: <->spacing), count: cols)
//        
//        ScrollView([.horizontal, .vertical]) {
//            ScrollViewReader { proxy in
//                LazyVGrid(columns: gridItems, spacing: |spacing) {
//                    ForEach(0..<defaultHexagonItemsList.count, id:\.self) { idx in
//                        HexagonCell(
//                            item: defaultHexagonItemsList[idx],
//                            isEnabled: focusHegaxonType == defaultHexagonItemsList[idx].type,
//                            action: { _ in focusPressed() }
//                        )
//                        .frame(width: <->width, height: |height)
//                        .offset(x: !isEvenRow(idx) ? 0 : <->width / 2 + (<->spacing/2))
//                        .frame(width: <->width, height: |height * 0.75)
//                    }
//                }
//                .scaleEffect(scale, anchor: UnitPoint(x: 0.35, y: 0.58))
//                .background(GeometryReader { geometry in
//                    Color.clear.onAppear {
//                        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
//                            scale = 2.8
//                        }
//                        withAnimation(.easeIn(duration: 0.6).delay(0.3)/*.delay(0.6)*/) {
//                            focusHegaxonType = .contacts
//                        }
//                    }
//                })
//            }
//        }
//        .scrollDisabled(true)
//        .background(Color.appBackground)
//        .edgesIgnoringSafeArea(.all)
//    }
//    
//    func isEvenRow(_ idx: Int) -> Bool { (idx / cols) % 2 == 0 }
//}
//
//#Preview {
//    ConnectHexagonContainerView(isFocusItemVerified: .constant(true), focusPressed: {}, selected: .contacts)
//}
