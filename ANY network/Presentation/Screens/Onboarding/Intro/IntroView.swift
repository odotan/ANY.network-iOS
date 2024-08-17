import SwiftUI

struct IntroView: View {
    @StateObject var viewModel: IntroViewModel
    @State private var previousAnimationEnd: Double = Constants.Delay.anyNetworkTextFadeIn
    @State private var showAnyNetworkText: Bool = false
    @State private var showYouAreCenterText: Bool = false
    @State private var showContactsApearText: Bool = false
    @State private var moveContactsApearText: Bool = false
    @State private var showAvatars: Bool = false
    @State private var blur: Bool = false
    @State private var popAvatarOut: Bool = false
    @State private var showTapAPerson: Bool = false
    @State private var movePopout: Bool = false
    @State private var tapANetwork: Bool = false
    @State private var avatarManager = AvatarIconManager(currentAvatarSet: AvatarIconManager.introMyAvatar)
    @State private var offset: CGFloat = .zero // the offset needed to possition cell 4x2 in the center
    @State private var myAvatarBottomEdge: CGFloat = .zero
    @State private var myAvatarPossition: CGPoint = .zero
    @State private var popoutAvatarPossition: CGPoint = .zero

    private let all = HexCell.all

    var body: some View {
        GeometryReader { reader in
            let size = reader.size
            Color.appBackground.ignoresSafeArea()
            HexGrid(
                all,
                spacing: 8,
                cornerRadius: 6,
                fixedCellSize: .init(width: <->80, height: |90),
                shadow: (color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
            ) { cell in
                cell.color
                    .overlay {
                        avatarCell(cell: cell)
                            .background(
                                GeometryReader { reader in
                                    Color.clear
                                        .onAppear {
                                            let frame = reader.frame(in: .global)
                                            setMyAvatarOffsetAndBottomEdge(containerSize: size, frame: frame, cell: cell)
                                            setMyAvatarPossition(containerSize: size, frame: frame, cell: cell)
                                            setPopoutPossition(containerSize: size, frame: frame, cell: cell)
                                        }
                                }
                            )
                    }
            }
            .blur(radius: blur ? 6 : 0)
            .scaleEffect(1.08)
            .overlay {
                popoutAvatar
            }

            Group {
                let containerCenter = CGPoint(x: size.width / 2, y: size.height / 2)

                Text(Constants.Strings.anyNetwork)
                    .opacity(showAnyNetworkText ? 1 : 0)
                    .position(x: containerCenter.x, y: (size.height / 6.5))

                Text(Constants.Strings.youAreCenter)
                    .opacity(showYouAreCenterText ? 1 : 0)
                    .position(x: containerCenter.x, y: myAvatarBottomEdge)

                Text(Constants.Strings.contactsApear)
                    .opacity(showContactsApearText ? 1 : 0)
                    .position(x: containerCenter.x, y: myAvatarBottomEdge + |20)
                    .offset(y: moveContactsApearText ? size.height / 2.37 : .zero)
                    .lineLimit(2)

                Text(Constants.Strings.tapAPerson)
                    .opacity(showTapAPerson ? 1 : 0)
                    .position(x: containerCenter.x, y: size.height / 1.12)

                Text(Constants.Strings.tapANetwork)
                    .opacity(tapANetwork ? 1 : 0)
                    .position(x: containerCenter.x, y: size.height / 1.1)
            }
            // For some reason there is space to the right,
            // but not to the left, so if you put `.horizontal`,
            // for the padding it moves the view only to the right.
            .padding(.trailing, <->40)
            .font(Font.montserat(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .transition(.opacity)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .lineSpacing(5)
            .onAppear {
                withAnimation(
                    .easeIn(duration: Constants.Duration.anyNetworkTextFadeIn)
                    .delay(Constants.Delay.anyNetworkTextFadeIn)) {
                        showAnyNetworkText = true
                        previousAnimationEnd += Constants.Duration.anyNetworkTextFadeIn + Constants.Delay.anyNetworkTextFadeOut
                    }
                withAnimation(
                    .easeIn(duration: Constants.Duration.anyNetworkTextFadeOut)
                    .delay(previousAnimationEnd)) {
                        showAnyNetworkText = false
                        previousAnimationEnd += Constants.Duration.anyNetworkTextFadeOut + Constants.Delay.myAvatarFadeIn
                    }
                withAnimation(
                    .easeIn(duration: Constants.Duration.myAvatarFadeIn)
                    .delay(previousAnimationEnd)) {
                        showAvatars = true
                        previousAnimationEnd += Constants.Duration.myAvatarFadeIn + Constants.Delay.youAreFadeIn
                    }
                withAnimation(
                    .easeIn(duration: Constants.Duration.youAreFadeIn)
                    .delay(previousAnimationEnd)) {
                        showYouAreCenterText = true
                        previousAnimationEnd += Constants.Duration.youAreFadeIn + Constants.Delay.youAreFadeOut
                    }
                withAnimation(
                    .easeIn(duration: Constants.Duration.youAreFadeOut)
                    .delay(previousAnimationEnd)) {
                        showYouAreCenterText = false
                        previousAnimationEnd += Constants.Duration.youAreFadeOut + Constants.Delay.contactsApearFadeIn
                    }
                withAnimation(
                    .easeIn(duration: Constants.Duration.contactsApearFadeIn)
                    .delay(previousAnimationEnd)) {
                        showContactsApearText = true
                        previousAnimationEnd += Constants.Duration.contactsApearFadeIn + Constants.Delay.firstSetOfAvatars
                    }
                withAnimation(
                    .smooth(duration: Constants.Duration.firstSetOfAvatars)
                    .delay(previousAnimationEnd)) {
                        moveContactsApearText = true
                        avatarManager.currentAvatarSet = AvatarIconManager.introFirstSetOfAvatars
                        previousAnimationEnd += Constants.Duration.firstSetOfAvatars + Constants.Delay.secondSetOfAvatars
                    }
                withAnimation(
                    .easeIn(duration: Constants.Duration.secondSetOfAvatars)
                    .delay(previousAnimationEnd)) {
                        avatarManager.currentAvatarSet = AvatarIconManager.introSecondSetOfAvatars
                        previousAnimationEnd += Constants.Duration.secondSetOfAvatars + Constants.Delay.thirdSetOfAvatars
                    }
                withAnimation(
                    .easeIn(duration: Constants.Duration.thirdSetOfAvatars)
                    .delay(previousAnimationEnd)) {
                        previousAnimationEnd += Constants.Duration.thirdSetOfAvatars + Constants.Delay.blur
                        avatarManager.currentAvatarSet = AvatarIconManager.introThirdSetOfAvatars
                        showContactsApearText = false
                    }
                withAnimation(
                    .easeIn(duration: Constants.Duration.blur)
                    .delay(previousAnimationEnd), {
                        popAvatarOut = true
                        blur = true
                        showTapAPerson = true
                        avatarManager.currentAvatarSet[16] = AvatarIcon(iconString: "avatar6x2", backgroundColor: .appPurple)
                        previousAnimationEnd += Constants.Duration.blur + Constants.Delay.movePopout +
                        Constants.Duration.movePopout + Constants.Delay.showContactMethods + Constants.Duration.showContactMethods + Constants.Delay.showTapANetwork
                        avatarManager.currentAvatarSet.remove(at: 16)
                    }, completion: {
                        withAnimation(
                            .easeOut(duration: Constants.Duration.movePopout)
                            .delay(Constants.Delay.movePopout), {
                                movePopout = true
                                blur = false
                                showTapAPerson = false
                                showAvatars = false
                                avatarManager.currentAvatarSet = []
                            }, completion: {
                                withAnimation(
                                    .easeIn(duration: Constants.Duration.showContactMethods)
                                    .delay(Constants.Delay.showContactMethods), {
                                        avatarManager.currentAvatarSet = AvatarIconManager.introContactMethods
                                        showAvatars = true
                                    }, completion: {
                                        withAnimation(
                                            .easeIn(duration: Constants.Duration.showTapANetwork)
                                            .delay(Constants.Delay.showTapANetwork), {
                                                tapANetwork = true
                                                previousAnimationEnd += Constants.Duration.showTapANetwork + Constants.Delay.end
                                            }, completion: {
                                                withAnimation(
                                                    .easeIn(duration: Constants.Duration.end)
                                                    .delay(Constants.Delay.end), {
                                                        tapANetwork = false
                                                        showAvatars = false
                                                        popAvatarOut = false
                                                    }, completion: {
                                                        viewModel.handle(.next)
                                                    })
                                            })
                                    })
                            })
                    })
            }
        }
        .ignoresSafeArea()
//        .onTapGesture {
//            viewModel.handle(.next)
//        }
    }

    private enum Constants {
        enum Delay {
            static let anyNetworkTextFadeIn = 0.8
            static let anyNetworkTextFadeOut = 2.0
            static let myAvatarFadeIn = 0.6
            static let youAreFadeIn = 1.0
            static let youAreFadeOut = 1.5
            static let contactsApearFadeIn = 1.0
            static let firstSetOfAvatars = 1.5
            static let secondSetOfAvatars = 0.6
            static let thirdSetOfAvatars = 0.6
            static let blur = 0.6
            static let movePopout = 0.6
            static let showContactMethods = 0.2
            static let showTapANetwork = 0.8
            static let end = 1.5
        }

        enum Duration {
            static let anyNetworkTextFadeIn = 0.8
            static let anyNetworkTextFadeOut = 0.4
            static let myAvatarFadeIn = 0.3
            static let youAreFadeIn = 0.4
            static let youAreFadeOut = 0.4
            static let contactsApearFadeIn = 1.0
            static let firstSetOfAvatars = 2.0
            static let secondSetOfAvatars = 1.0
            static let thirdSetOfAvatars = 0.8
            static let blur = 1.0
            static let movePopout = 0.8
            static let showContactMethods = 0.8
            static let showTapANetwork = 1.0
            static let end = 1.5
        }

        enum Strings {
            static let anyNetwork = "ANY network is a new way to\ninteract with your contacts"
            static let youAreCenter = "You are in the center"
            static let contactsApear = "And your contacts appear around\nyou as you interact with them"
            static let tapAPerson = "Tap a person to view their card"
            static let tapANetwork = "Then tap a network to interact with them on that app."
        }
    }

    @ViewBuilder
    private var popoutAvatar: some View {
        let avatar = AvatarIcon(iconString: "avatar6x2", backgroundColor: .appPurple)

        avatar.icon
            .resizable()
            .scaledToFit()
            .frame(width: <->80, height: |90)
            .offset(y: |5)
            .transition(.opacity)
            .opacity(popAvatarOut ? 1 : 0)
            .background(
                avatar.backgroundColor
                    .opacity(popAvatarOut ? 1 : 0)
            )
            .clipShape(HexagonShape(cornerRadius: 6))
            .position(popoutAvatarPossition)
            .offset(x: myAvatarPossition.x)
            .offset(y: movePopout ? myAvatarPossition.y - popoutAvatarPossition.y : .zero)
    }

    @ViewBuilder
    private func avatarCell(cell: HexCell) -> some View {
        if let avatar = avatarManager.currentAvatarSet.first(where: {
            $0.position ?? avatarManager.getOffsetCoordinate(of: $0) == cell.offsetCoordinate
        }) {
            let smallIcons = avatarManager.currentAvatarSet == AvatarIconManager.introContactMethods
            ZStack {
                avatar.backgroundColor
                    .opacity(showAvatars ? 1 : 0)
                avatar.icon
                    .renderingMode(smallIcons ? .template : .original)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: smallIcons ? <->30 : nil, height: smallIcons ? |30 : nil, alignment: .center)
                    .opacity(showAvatars ? 1 : 0)
                    .offset(y: smallIcons ? .zero : |5)
                    .transition(.opacity)
            }
        }
    }

    private func setMyAvatarOffsetAndBottomEdge(containerSize: CGSize, frame: CGRect, cell: HexCell) {
        if cell.offsetCoordinate == OffsetCoordinate(row: 4, col: 2) {
            offset = (containerSize.width / 2) - (frame.origin.x + frame.width / 2)
            myAvatarBottomEdge = frame.maxY + |30
        }
    }

    private func setMyAvatarPossition(containerSize: CGSize, frame: CGRect, cell: HexCell) {
        if cell.offsetCoordinate == OffsetCoordinate(row: 4, col: 2) {
            myAvatarPossition = .init(x: frame.midX, y: frame.minY + frame.height / 2)
        }
    }

    private func setPopoutPossition(containerSize: CGSize, frame: CGRect, cell: HexCell) {
        if cell.offsetCoordinate == OffsetCoordinate(row: 6, col: 2) {
            popoutAvatarPossition = .init(x: containerSize.width / 2, y: frame.minY)
        }
    }
}

#Preview {
    IntroView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {})))
}
