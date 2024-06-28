import SwiftUI

struct ContactsPermissionView: View {
    @StateObject var viewModel: ContactsPermissionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image(.onboarding1Contacts)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, <->86)
                    .padding(.bottom, |33)
                
                Group {
                    Text(Constants.Strings.title)
                        .font(.system(size: |21, weight: .bold))
                        .lineSpacing(|3.5)
                        .padding(.bottom, |25)
                    
                    Text(Constants.Strings.subText1)
                        .padding(.bottom, |14)
                    
                    Text(Constants.Strings.subText2)
                        .padding(.bottom, |25)
                    
                    Text(Constants.Strings.subText3)
                        .padding(.bottom, |58)
                }
                .font(.custom(Font.montseratRegular, size: |14))
                .lineSpacing(|4)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            }
        }
        .backButton {
            viewModel.handle(.goBack)
        }
        .navigationBarHidden(true)
        .padding(.bottom, |140)
        .background(
            HexagonBackground(icon: {
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
            }, action: {
                viewModel.handle(.allow)
            })
        )
        .overlay(alignment: .bottom, content: {
            PlainTextButton(text: Constants.Strings.skipButton, action: {
                viewModel.handle(.skip)
            })
            .frame(width: <->79.93)
            .padding(.vertical, |4)
            .offset(x: <->(79.93 + 7.7))
        })
    }
    
    private enum Constants {
        enum Strings {
            static let title = "Your Contacts -\nSupercharged!"
            static let subText1 = """
                ANY network needs contact permissions to
                give you a new phone-book experience.
            """
            static let subText2 = """
                It will still work without contact permissions, but
                it won’t show your contact list.
            """
            static let subText3 = """
                Even if you allow, your contacts will not be
                shared with ANY servers without your consent
                
                You can change this at any time under Settings
            """
            static let allowButton = "Allow Contact Permissions"
            static let skipButton = "Skip"
        }
    }
}

#Preview {
    ContactsPermissionView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {}), getRequestAccessUseCase: .init(repository: ContactsService())))
}
