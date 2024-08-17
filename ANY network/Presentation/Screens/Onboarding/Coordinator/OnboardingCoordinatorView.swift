import SwiftUI

struct OnboardingCoordinatorView: View {
    private let factory: OnboardingCoordinatorFactory
    @ObservedObject private var coordinator: OnboardingCoordinator

    init(_ coordinator: OnboardingCoordinator, factory: OnboardingCoordinatorFactory) {
        self.factory = factory
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            factory.makeIntro(coordinator: coordinator)
                .navigationDestination(for: OnboardingCoordinator.Screen.self) {
                    destination($0)
                }
        }
    }

    @ViewBuilder
    private func destination(_ screen: OnboardingCoordinator.Screen) -> some View {
        switch screen {
        case .intro:
            factory.makeIntro(coordinator: coordinator)
        }
    }
}
