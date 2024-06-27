import SwiftUI

struct ContactsPermissionView: View {
    @StateObject var viewModel: ContactsPermissionViewModel
    
    private let hexagonSize: CGSize = {
        let spacing = 8
        let screenWidth = UIScreen.current!.bounds.width
        let width = (screenWidth - CGFloat(spacing * 5)) / 5
        let height = tan(Angle(degrees: 30).radians) * width * 2
        return CGSize(width: width, height: height)
    }()
    
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
                    .lineSpacing(7)   
                }
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                
                Spacer()

                PlainTextButton(text: Constants.Strings.skipButton, action: {
                    viewModel.handle(.skip)
                })
                .offset(x: hexagonSize.width)
            }
            .backButton {
                viewModel.handle(.goBack)
            }
            .frame(width: size.width, height: size.height)
            .navigationBarHidden(true)
            .padding(.bottom, hexagonSize.height)
            .background(HexagonBackground(icon: {
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
            }, action: {
                viewModel.handle(.allow)
            }))
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
