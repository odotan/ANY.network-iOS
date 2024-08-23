import SwiftUI

enum DrawerPosition {
    case top
    case bottom
}

struct DrawerView<Content: View, DrawerContent: View>: View {
    var content: () -> Content
    var drawerContent: () -> DrawerContent
    private let bottomDrawerHeight: CGFloat = 70
    private let drawerTopCornersRadius: CGFloat = 35
    private let ignoreTopSafeAreas: Bool = false
    
    @Binding var contentHeight: CGFloat
    @State var lastOffset: CGFloat = 0
    @State var size: CGSize = .zero
        
    @GestureState var gestureOffset: CGFloat = 0
    
    init(
        contentHeight: Binding<CGFloat>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder drawerContent: @escaping () -> DrawerContent
    ) {
        _contentHeight = contentHeight
        self.content = content
        self.drawerContent = drawerContent
    }
    
    var body: some View {
        VStack {
            content()
                .frame(height: contentHeight)
            
            Spacer()
        }
        .overlay {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: contentHeight - 30)
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 20)
                    
                    drawerContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .overlay(alignment: .top, content: {
                    pullUpView
                })
                .background(Color.appBackground)
                .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: self.drawerTopCornersRadius))
            }
        }
        .ignoresSafeArea(.all, edges: self.ignoreTopSafeAreas ? [.top, .bottom] : [.bottom])
        .sizeInfo(size: $size)
    }
    
    @ViewBuilder
    var pullUpView: some View {
        Color.white.opacity(0.6)
            .clipShape(RoundedRectangle(cornerRadius: 1))
            .frame(maxWidth: .infinity)
            .frame(width: 74, height: 3)
            .padding(.top, 13)
            .padding(.bottom, 23)
            .frame(maxWidth: .infinity)
            .background(Color.appBackground)
            .gesture(
                DragGesture()
                    .updating(self.$gestureOffset, body: { value, out, _ in
                        out = value.translation.height
                        DispatchQueue.main.async {
                            var new = contentHeight + gestureOffset
                            new = new > size.height - bottomDrawerHeight ? size.height - bottomDrawerHeight : new
                            new = new < 180 ? 180 : new
                            self.contentHeight = new
                        }
                    })
            )
    }
}

struct DrawerModifier<DrawerContent: View>: ViewModifier {
    var contentHeight: Binding<CGFloat>
    var drawerContent: () -> DrawerContent
    
    func body(content: Content) -> some View {
        DrawerView(contentHeight: contentHeight, content: { content }, drawerContent: drawerContent)
    }
}
// View extension
extension View {
    func bottomDrawerView<DrawerContent: View>(contentHeight: Binding<CGFloat>, @ViewBuilder drawerContent: @escaping () -> DrawerContent) -> some View {
        self.modifier(DrawerModifier(contentHeight: contentHeight, drawerContent: drawerContent))
    }
}

struct CustomCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
