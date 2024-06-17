import SwiftUI

struct IntroView: View {
    @StateObject var viewModel: IntroViewModel
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                ScrollView {
                    Image(.onboarding1Contacts)
                        .resizable()
                        .scaledToFit()
                        .frame(height: size.height / 3)
                        .padding(.bottom, 25)
                    
                    Group {
                        Text(Constants.Strings.title)
                            .font(.system(size: 21, weight: .bold))
                            .lineSpacing(3.5)
                            .padding(.bottom, 25)
                        
                        Text(Constants.Strings.subText)
                            .padding(.bottom, 58)
                            .font(.custom(Font.montseratRegular, size: 14))
                            .lineSpacing(5)
                        
                    }
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                }

                HexagonButton(title: Constants.Strings.nextButton, action: {
                    viewModel.handle(.next)
                })
                .padding(.bottom, 26)
            }
            .background(
                Image(.onboarding1Background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .bottom)
                    .frame(width: size.width, height: size.height, alignment: .bottom)
                    .offset(y: size.height / 10)
            )
        }
    }
    
    private enum Constants {
        enum Strings {
            static let title = "ANY network -\ncontacts re-imagined"
            static let subText = """
                Create your card with all your contact methods

                Phone, email, Instagram, Telegram etc…

                any network really

                Your card is private by default and cannot be seen by anyone

                People you share your card with can request to see any part of your card, and you can choose to show it to them

                You can make part or all of your card public
            """
            static let nextButton = "Next"
            static let skipButton = "Skip"
        }
    }
}

#Preview {
    IntroView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {})))
}
