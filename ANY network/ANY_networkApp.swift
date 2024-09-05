import SwiftUI

@main
struct ANY_networkApp: App {
    @State var animationFinished: Bool = false
    
    let appFactory = AppFactory()

    var body: some Scene {
        WindowGroup {
            destination
                .background(SceneHandlerView())
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

struct SceneHandlerView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        EmptyView()
            .onChange(of: scenePhase) { _ , newPhase in
                switch newPhase {
                case .active:
                    print("App is active")
                    do {
                        try HepticService.shared.start()
                    } catch {
                        print("Error starting Heptic Service:", error.localizedDescription)
                    }
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
