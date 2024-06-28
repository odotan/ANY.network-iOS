import SwiftUI

struct IntroView: View {
    @StateObject var viewModel: IntroViewModel
    
    var body: some View {
        ScrollView {
            Image(.introHeader)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, <->51)
                .padding(.bottom, |25)
            
            Group {
                Text(Constants.Strings.title)
                    .font(.system(size: |21, weight: .bold))
                    .lineSpacing(|3.5)
                    .padding(.bottom, |25)
                
                Text(Constants.Strings.subText)
                    .padding(.bottom, |58)
                    .font(.custom(Font.montseratRegular, size: |13))
                    .lineSpacing(|4)
                    .kerning(0)
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, <->16)
        }
        .padding(.bottom, |130)
        .background(HexagonBackground(icon: {
            Image(systemName: "chevron.right")
                .resizable()
                .foregroundColor(.white)
                .scaledToFit()
        }, action: {
            viewModel.handle(.next)
        }))
    }
    
    private enum Constants {
        enum Strings {
            static let title = "ANY network\ncontacts re-imagined"
            static let subText = """
                Create your card with all your contact methods
                Phone, email, Instagram, Telegram etc…

                any network really

                Your card is private by default and cannot be seen by anyone. People you share your card with can request to see any part of your card, and you can choose to show it to them You can make part or all of your card public
            """
            static let nextButton = "Next"
            static let skipButton = "Skip"
        }
    }
}

#Preview {
    IntroView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {})))
        .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
}
