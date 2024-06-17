import SwiftUI

struct MainCoordinatorView: View {
    private let factory: MainCoordinatorFactory
    @ObservedObject private var coordinator: MainCoordinator

    init(_ coordinator: MainCoordinator, factory: MainCoordinatorFactory) {
        self.factory = factory
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            factory.makeHome(coordinator: coordinator)
                .navigationDestination(for: MainCoordinator.Screen.self) {
                    destination($0)
                }
        }
    }

    @ViewBuilder
    private func destination(_ screen: MainCoordinator.Screen) -> some View {
        switch screen {
        case .home:
            factory.makeHome(coordinator: coordinator)
        case .myProfile:
            factory.makeMyProfile(coordinator: coordinator)
        }
    }
}
