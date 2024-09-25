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
    func makeMyProfile(coordinator: MainCoordinatorProtocol) -> MyProfileView
}

@MainActor
protocol DetailsFactory {
    func makeDetails(contact: Contact, isNew: Bool, coordinator: MainCoordinatorProtocol) -> DetailsView
}

@MainActor
protocol SearchFactory {
    func makeSearch(coordinator: MainCoordinatorProtocol) -> SearchView
}
