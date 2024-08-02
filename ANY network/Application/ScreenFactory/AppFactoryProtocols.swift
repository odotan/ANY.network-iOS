import SwiftUI


// MARK: Onboarding
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


// MARK: Main
@MainActor
protocol HomeFactory {
    func makeHome(coordinator: MainCoordinatorProtocol) -> HomeView
}

@MainActor
protocol MyProfileFactory {
    func makeMyProfile(coordinator: MainCoordinatorProtocol) -> MyProfileView
}

@MainActor
protocol DetailsFactory {
    func makeDetails(contact: Contact, coordinator: MainCoordinatorProtocol) -> DetailsView
}

@MainActor
protocol SearchFactory {
    func makeSearch(coordinator: MainCoordinatorProtocol) -> SearchView
}
