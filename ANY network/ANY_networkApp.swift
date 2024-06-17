import SwiftUI

@main
struct ANY_networkApp: App {
    let appFactory = AppFactory()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(
                screenFactory: ScreenFactory(appFactory: appFactory),
                coordinator: AppCoordinator(getContactsStatusUseCase: appFactory.makeContactsStatus())
            )
        }
    }
}
