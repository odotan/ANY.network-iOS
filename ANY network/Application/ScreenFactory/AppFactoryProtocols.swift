import SwiftUI


// MARK: Onboarding
@MainActor
protocol IntroFactory {
    func makeIntro(coordinator: OnboardingCoordinatorProtocol) -> IntroView
}

// MARK: Main
@MainActor
protocol HomeFactory {
    func makeHome(coordinator: MainCoordinatorProtocol) -> HomeView
}

@MainActor
protocol MyProfileFactory {
    func makeMyProfile(coordinator: MainCoordinatorProtocol, onDismiss: @escaping () -> Void) -> MyProfileView
}

@MainActor
protocol DetailsFactory {
    func makeDetails(
        contact: Contact,
        isNew: Bool,
        onContactChangeEvent: @escaping (ContactChangeEvent) -> Void,
        coordinator: MainCoordinatorProtocol
    ) -> DetailsView
}

@MainActor
protocol SearchFactory {
    func makeSearch(
        onContactChangeEvent: @escaping (ContactChangeEvent) -> Void,
        coordinator: MainCoordinatorProtocol
    ) -> SearchView
}

@MainActor
protocol ConnectFactory {
    func makeConnect(contact: Contact, coordinator: any MainCoordinatorProtocol) -> ConnectView
}

@MainActor
protocol ConnectNetworkSignUpFactory {
    func makeConnectNetworkSignUp(networkItem: NetworkItem, contact: Contact, coordinator: any MainCoordinatorProtocol) -> ConnectNetworkSignUpView
}

@MainActor
protocol ConnectNetworkConfirmationFactory {
    func makeConnectNetworkConfirmation(networkItem: NetworkItem, coordinator: MainCoordinatorProtocol) -> ConnectNetworkConfirmationView
}

@MainActor
protocol RequestNetworkFactory {
    func makeRequestNetwork(contact: Contact, coordinator: MainCoordinatorProtocol) -> RequestNetworkView
}

@MainActor
protocol HiUFactory {
    func makeHiU(coordinator: MainCoordinatorProtocol) -> HiUHomeView
}
