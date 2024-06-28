import SwiftUI

struct LandingView: View {
    @Binding var animationFinished: Bool
    @State private var showTopImage = false
    @State private var showMiddleImage1 = false
    @State private var showMiddleImage2 = false
    @State private var showByImage = false
    @State private var showBottomImage = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showTopImage {
                Image(.landingTop)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->143, height: |180)
                    .padding(.top, |151)
                    .transition(.opacity)
            }
            
            if showMiddleImage1 {
                Image(.landingMiddle1)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->136, height: |39.5)
                    .padding(.top, |24)
                    .transition(.opacity)
            }
            
            if showMiddleImage2 {
                Image(.landingMiddle2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->102, height: |13)
                    .padding(.top, |16)
                    .transition(.opacity)
            }
            
            Spacer()

            if showByImage {
                Image(.landingBy)
                    .resizable()
                    .scaledToFit() 
                    .frame(width: <->15, height: |33.35)
                    .padding(.bottom, |10)
                    .offset(x: 8)
                    .offset(y: showBottomImage ? 0 : -(|126))
                    .transition(.opacity)
            }
            
            if showBottomImage {
                Image(.landingBtp)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->106, height: |54)
                    .transition(.opacity)
                    .padding(.bottom, |72)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .edgesIgnoringSafeArea(.all)
        .background(Color.appBackground)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showTopImage = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                showMiddleImage1 = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                showMiddleImage2 = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.5)) {
                showByImage = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(2.0)) {
                showBottomImage = true
            } completion: {
                withAnimation(.easeInOut.delay(0.5)) {
                    self.animationFinished = true
                }
            }
        }
    }
}

#Preview {
    LandingView(animationFinished: .constant(true))
}
