import SwiftUI

@main
struct ANY_networkApp: App {
    @State var animationFinished: Bool = false
    let appFactory = AppFactory()

    var body: some Scene {
        WindowGroup {
            destination
        }
    }
    
    @ViewBuilder
    var destination: some View {
        if !animationFinished {
            LandingView(animationFinished: $animationFinished)
                .transition(.move(edge: .leading))
        } else {
            AppCoordinatorView(
                screenFactory: ScreenFactory(appFactory: appFactory),
                coordinator: AppCoordinator(getContactsStatusUseCase: appFactory.makeContactsStatus())
            )
            .transition(.move(edge: .trailing))
        }
    }
}
