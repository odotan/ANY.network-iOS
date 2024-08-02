import SwiftUI

struct DrawerViewModifier<Slide: Gesture>: ViewModifier {
    private var dragGesture: Slide
    
    init(dragGesture: Slide) {
        self.dragGesture = dragGesture
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top, content: { drawer })
            .frame(maxWidth: .infinity)
            .background(Color.appBackground)
    //        .clipShape(RoundedRectangle(cornerRadius: 50))
            //.cornerRadiusWithBorder(cornerRadii: .init(topLeading: 50, topTrailing: 50), borderColor: Color.white.opacity(0.14))
    //        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 50, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: -50.0)
            .overlay(alignment: .top) {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.5), Color.black.opacity(0)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: |81)
                .offset(y: -(|81))
            }
    }
    
    @ViewBuilder
    @MainActor
    var drawer: some View {
        RoundedRectangle(cornerRadius: 3)
            .foregroundColor(.white.opacity(0.4))
            .frame(width: <->72, height: |3)
            .padding(.top, |14)
            .padding(.bottom, |30)
            .padding(.horizontal, <->30)
            .background(Color.appBackground)
            .gesture(dragGesture)
    }
}

extension View {
    func drawer<Slide: Gesture>(dragGesture: Slide) -> some View {
        modifier(DrawerViewModifier(dragGesture: dragGesture))
    }
}

#Preview {
    VStack {
        Text("Hello World")
            .font(.title)
        Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(.red)
    .drawer(dragGesture: DragGesture())
}
