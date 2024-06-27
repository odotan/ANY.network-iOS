import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        HomeViewTemp()
    }
}

struct HomeViewTemp: View {
    private let initialHeight: CGFloat = 300

    @State var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                favourites
                recently
            }
        }
        .background(Color.appBackground)
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    var favourites: some View {
        Color.clear
    }
    
    @ViewBuilder
    var recently: some View {
        VStack {
            DragableView(offset: $offset)
                
            Spacer()
        }
        .frame(height: UIScreen.main.bounds.height - initialHeight - offset)
        .frame(maxWidth: .infinity)
        .background(Color.appBackground)
//        .clipShape(RoundedRectangle(cornerRadius: 50))
        //.cornerRadiusWithBorder(cornerRadii: .init(topLeading: 50, topTrailing: 50), borderColor: Color.white.opacity(0.14))
        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 50, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: -50)
    }
}

#Preview {
    HomeViewTemp()
}


struct DragableView: View {
    @Binding var offset: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .foregroundColor(.white.opacity(0.4))
            .frame(width: 72, height: 3)
            .padding(.top, 14)
            .padding(.bottom, 30)
            .padding(.horizontal, 30)
            .background(Color.appBackground)
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        offset += drag.translation.height
//                        print(offset)
                    }
            )
    }
}
