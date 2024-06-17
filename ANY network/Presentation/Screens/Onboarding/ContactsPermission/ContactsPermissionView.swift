import SwiftUI

struct ContactsPermissionView: View {
    @StateObject var viewModel: ContactsPermissionViewModel
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            Color.appBackground.ignoresSafeArea()
            
            VStack {
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
                    
                    Group {
                        Text(Constants.Strings.subText1)
                            .padding(.bottom, 14)
                        
                        Text(Constants.Strings.subText2)
                            .padding(.bottom, 25)
                        
                        Text(Constants.Strings.subText3)
                            .padding(.bottom, 58)
                    }
                    .font(.custom(Font.montseratRegular, size: 14))
                    .lineSpacing(5)
                    
                }
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                
                HexagonButton(title: Constants.Strings.allowButton, action: {
                    viewModel.handle(.allow)
                })
                .padding(.bottom, 26)
                
                PlainTextButton(text: Constants.Strings.skipButton, action: {
                    viewModel.handle(.skip)
                })
            }
            .backButton {
                viewModel.handle(.goBack)
            }
            .frame(width: size.width, height: size.height)
            .navigationBarHidden(true)
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

