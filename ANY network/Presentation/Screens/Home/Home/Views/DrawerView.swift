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
    private let showButtons: Bool

    @GestureState var gestureOffset: CGFloat = 0

    private let searchAction: () -> Void
    private let recenterAction: () -> Void

    init(
        contentHeight: Binding<CGFloat>,
        showButtons: Bool = true,
        searchAction: @escaping () -> Void,
        recenterAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder drawerContent: @escaping () -> DrawerContent
    ) {
        _contentHeight = contentHeight
        self.showButtons = showButtons
        self.searchAction = searchAction
        self.recenterAction = recenterAction
        self.content = content
        self.drawerContent = drawerContent
    }

    var body: some View {
        VStack {
            content()

            Spacer()
                .background(.clear)
        }
        .overlay {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: contentHeight - 30)

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 38)
                    
                    drawerContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.clear)
                        .mask {
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: 20)

                                LinearGradient(
                                    stops: [.init(color: .clear, location: 0),
                                            .init(color: .black, location: 0.5)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 50)
                                
                                Color.black
                            }
                        }
                }
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .background(ZStack { Color.appBackground.opacity(0.8) })
                )
                .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: self.drawerTopCornersRadius))
                .overlay(alignment: .top) { pullUpView }
                .overlay(alignment: .top) {
                    HStack {
                        SearchButton(action: searchAction)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RecenterButton(action: recenterAction)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .opacity(showButtons ? 1 : 0)
                }
            }
        }
        .ignoresSafeArea(.all, edges: self.ignoreTopSafeAreas ? [.top, .bottom] : [.bottom])
        .sizeInfo(size: $size)
    }

    @ViewBuilder
    var pullUpView: some View {
        HStack {
            SearchButton(action: searchAction)
                .opacity(0)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Color.white.opacity(0.6)
                .clipShape(RoundedRectangle(cornerRadius: 1))
                .frame(maxWidth: .infinity)
                .frame(width: 74, height: 3, alignment: .top)
                .padding(.bottom, 23)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle()) // Because of Color.clear touches needs this.
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

#Preview {
    ZStack {
        Color.appBackground.opacity(0.7).ignoresSafeArea()
            .bottomDrawerView(
                contentHeight: .constant(250),
                showButtons: true,
                searchAction: { },
                recenterAction: { }
            ) {
                ScrollView {
                    VStack {
                        ForEach(0..<150) { idx in
                            Text(idx.description + "Ааааааааааааааа")
                                .foregroundStyle(.white)
                                .font(.system(size: 40))
                        }
                    }
                }
            }
    }
}

struct DrawerModifier<DrawerContent: View>: ViewModifier {
    var contentHeight: Binding<CGFloat>
    var showButtons: Bool
    var searchAction: () -> Void
    var recenterAction: () -> Void
    var drawerContent: () -> DrawerContent

    func body(content: Content) -> some View {
        DrawerView(contentHeight: contentHeight,
                   showButtons: showButtons,
                   searchAction: searchAction,
                   recenterAction: recenterAction,
                   content: { content },
                   drawerContent: drawerContent)
    }
}
// View extension
extension View {
    func bottomDrawerView<DrawerContent: View>(
        contentHeight: Binding<CGFloat>,
        showButtons: Bool,
        searchAction: @escaping () -> Void,
        recenterAction: @escaping () -> Void,
        @ViewBuilder drawerContent: @escaping () -> DrawerContent
    ) -> some View {
        self.modifier(DrawerModifier(
            contentHeight: contentHeight,
            showButtons: showButtons,
            searchAction: searchAction,
            recenterAction: recenterAction,
            drawerContent: drawerContent)
        )
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
