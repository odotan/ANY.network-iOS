import SwiftUI

@main
struct ANY_networkApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    @State var animationFinished: Bool = false
    let appFactory = AppFactory()
    
    var body: some Scene {
        WindowGroup {
            destination
                .onChange(of: scenePhase) { _ , newPhase in
                    switch newPhase {
                    case .active:
                        print("App is active")
                        try? HepticService.shared.start()
                    case .inactive:
                        print("App is inactive")
                    case .background:
                        print("App is in background")
                        HepticService.shared.stop()
                    @unknown default:
                        print("Unknown phase")
                    }
                }
        }
    }
    
    @ViewBuilder
    var destination: some View {
        if !animationFinished {
            LandingView(animationFinished: $animationFinished)
                .transition(.opacity)
        } else {
            AppCoordinatorView(
                screenFactory: ScreenFactory(appFactory: appFactory),
                coordinator: AppCoordinator(getContactsStatusUseCase: appFactory.makeContactsStatus())
            )
            .transition(.opacity)
        }
    }
}
