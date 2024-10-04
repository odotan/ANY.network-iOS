import SwiftUI

struct LandingView: View {
    @Binding var animationFinished: Bool
    @State private var showLogo = false
    @State private var showLabel = false
    @State private var changeImages = false
    @State private var scale: CGFloat = 1
    @State private var changeBackgroundColor = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: |238)

            Image(!changeImages ? .landingLogo : .landingLogoHex)
                .resizable()
                .scaledToFit()
                .frame(width: <->143, height: |180.54)
                .opacity(showLogo ? 1 : 0)
                .scaleEffect(scale, anchor: .init(x: 0.45, y: 0.25))
                .transition(.opacity)
            
            Group {
                Image(.landingAny)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->136, height: |39.5)
                    .padding(.top, |23.85)
                
                Image(.landingNetwork)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->102, height: |13.08)
                    .padding(.top, |15.5)
            }
            .opacity(showLabel ? 1 : 0)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .edgesIgnoringSafeArea(.all)
        .background(Color.appBackground)
        .onTapGesture {
            self.animationFinished = true
        }
        .onAppear {
            let launchAnimationPlayed = UserDefaults.standard.bool(forKey: "launch-animation-played")
            if !launchAnimationPlayed {
                firstLaunchAnimation()
            } else {
                subsequentLaunchesAnimation()
            }
        }
    }

    func firstLaunchAnimation() {
        withAnimation(
            .easeIn(duration: Constants.Duration.showLogo)
            .delay(Constants.Delay.initial)
        ) {
            showLogo = true
        }
        withAnimation(
            .easeIn(duration: Constants.Duration.showLabel)
            .delay(Constants.Delay.showLabel)
        ) {
            showLabel = true
        }
        withAnimation(
            .easeIn(duration: Constants.Duration.purpleHexagon)
            .delay(Constants.Delay.purpleHexagon)
        ) {
            showLabel = false
            changeImages = true
        }
        withAnimation(
            .easeIn(duration: Constants.Duration.purpleHexagonScale)
            .delay(Constants.Delay.purpleHexagonScale)
        ) {
            scale = 30
        } completion: {
            withAnimation(
                .easeIn(duration: Constants.Duration.switchScreens)
                .delay(Constants.Delay.switchScreens)
            ) {
                UserDefaults.standard.setValue(true, forKey: "launch-animation-played")
                self.animationFinished = true
            }
        }
    }

    func subsequentLaunchesAnimation() {
        withAnimation(
            .easeIn(duration: Constants.Duration.showLogo)
        ) {
            showLogo = true
            showLabel = true
        } completion: {
            withAnimation(
                .easeIn(duration: Constants.Duration.hideLabelOnSubsequentLaunches)
                .delay(Constants.Delay.hideLabelOnSubsequentLaunches)
            ) {
                showLabel = false
                changeImages = true
            } completion: {
                withAnimation(
                    .easeIn(duration: Constants.Duration.hexagonScaleOnSubsequentLaunches)
                    .delay(Constants.Delay.hexagonScaleOnSubsequentLaunches)
                ) {
                    scale = 30
                } completion: {
                    withAnimation(
                        .easeIn(duration: Constants.Duration.switchScreensOnSubsequentLaunches)
                        .delay(Constants.Delay.switchScreensOnSubsequentLaunches)
                    ) {
                        self.animationFinished = true
                    }
                }
            }
        }
    }

    // MARK: -- OFIR
    private enum Constants {
        enum Delay {
            static let initial: CGFloat = 0.8
            static let showLabel: CGFloat = 1.8 // 1.6 + 0.2
            static let purpleHexagon: CGFloat = 3.4 // 2.6 + 0.8
            static let purpleHexagonScale: CGFloat = 4.7 // 4.6 + 0.1
            static let switchScreens: CGFloat = 0.4

            static let hideLabelOnSubsequentLaunches: CGFloat = 0.3
            static let hexagonScaleOnSubsequentLaunches: CGFloat = 0.3
            static let switchScreensOnSubsequentLaunches: CGFloat = 0.3
        }

        enum Duration {
            static let showLogo: CGFloat = 0.8
            static let showLabel: CGFloat = 0.8
            static let purpleHexagon: CGFloat = 1
            static let purpleHexagonScale: CGFloat = 1
            static let switchScreens: CGFloat = 1.5

            static let showLogoOnSubsequentLaunches: CGFloat = 0.35
            static let hideLabelOnSubsequentLaunches: CGFloat = 0.35
            static let hexagonScaleOnSubsequentLaunches: CGFloat = 0.5
            static let switchScreensOnSubsequentLaunches: CGFloat = 0.35
        }
    }
}

#Preview {
    LandingView(animationFinished: .constant(true))
}
