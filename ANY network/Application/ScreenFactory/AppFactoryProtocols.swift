import SwiftUI

@MainActor
protocol IntroFactory {
    func makeIntro(coordinator: OnboardingCoordinatorProtocol) -> IntroView
}

@MainActor
protocol ContactsPermissionFactory {
    func makeContactsPermission(coordinator: OnboardingCoordinatorProtocol) -> ContactsPermissionView
}

@MainActor
protocol ConnectFactory {
    func makeConnect(coordinator: OnboardingCoordinatorProtocol) -> ConnectView
}

@MainActor
protocol HomeFactory {
    func makeHome(coordinator: MainCoordinatorProtocol) -> HomeView
}

@MainActor
protocol MyProfileFactory {
    func makeMyProfile(coordinator: MainCoordinatorProtocol) -> MyProfileView
}
