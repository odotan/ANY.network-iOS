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
                    .frame(relevantWidth: 143, relevantHeight: 180)
                    .padding(.top, relevantLength: 151)
                    .transition(.opacity)
            }
            
            if showMiddleImage1 {
                Image(.landingMiddle1)
                    .resizable()
                    .scaledToFit()
                    .frame(relevantWidth: 136, relevantHeight: 39.5)
                    .padding(.top, relevantLength: 24)
                    .transition(.opacity)
            }
            
            if showMiddleImage2 {
                Image(.landingMiddle2)
                    .resizable()
                    .scaledToFit()
                    .frame(relevantWidth: 102, relevantHeight: 13)
                    .padding(.top, relevantLength: 16)
                    .transition(.opacity)
            }
            
            Spacer()

            if showByImage {
                Image(.landingBy)
                    .resizable()
                    .scaledToFit()
                    .frame(relevantWidth: 15, relevantHeight: 33.35)
                    .padding(.bottom, relevantLength: 10)
                    .offset(x: 8)
                    .offset(relevantY: showBottomImage ? 0 : -126)
                    .transition(.opacity)
            }
            
            if showBottomImage {
                Image(.landingBtp)
                    .resizable()
                    .scaledToFit()
                    .frame(relevantWidth: 106, relevantHeight: 54)
                    .transition(.opacity)
                    .padding(.bottom, relevantLength: 72)
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
