import Foundation

final class ScreenFactory: OnboardingCoordinatorFactory, 
                            MainCoordinatorFactory {

    private let appFactory: AppFactory
    
    init(appFactory: AppFactory) {
        self.appFactory = appFactory
    }
}

// MARK: Onboarding
extension ScreenFactory: IntroFactory {
    func makeIntro(coordinator: OnboardingCoordinatorProtocol) -> IntroView {
        let viewModel = IntroViewModel(coordinator: coordinator)
        let view = IntroView(viewModel: viewModel)

        return view
    }
}

// MARK: Main
extension ScreenFactory: HomeFactory {
    func makeHome(coordinator: MainCoordinatorProtocol) -> HomeView {
        let viewModel = HomeViewModel(
            coordinator: coordinator,
            getFavoriteContactsUseCase: appFactory.makeGetFavoriteContacts(),
            getAllContactsUseCase: appFactory.makeGetAll(),
            searchUseCase: appFactory.makeSearch(),
            getContactsStatusUseCase: appFactory.makeContactsStatus(),
            getRequestAccessUseCase: appFactory.makeRequestAccess()
        )

        let view = HomeView(viewModel: viewModel)

        return view
    }
}

extension ScreenFactory: MyProfileFactory {
    func makeMyProfile(coordinator: MainCoordinatorProtocol) -> MyProfileView {
        let viewModel = MyProfileViewModel(coordinator: coordinator)
        let view = MyProfileView(viewModel: viewModel)
        
        return view
    }
}

extension ScreenFactory: DetailsFactory {
    func makeDetails(contact: Contact, coordinator: MainCoordinatorProtocol) -> DetailsView {
        let viewModel = DetailsViewModel(
            contact: contact,
            coordinator: coordinator,
            toggleFavoriteUseCase: appFactory.makeToggleFavorite(),
            checkIfFavoriteUseCase: appFactory.makeCheckIfFavorite(),
            createEditContactUseCase: appFactory.makeCreateEditContactUseCase()
        )
        let view = DetailsView(viewModel: viewModel)
        
        return view
    }
}

extension ScreenFactory: SearchFactory {
    func makeSearch(coordinator: MainCoordinatorProtocol) -> SearchView {
        let viewModel = SearchViewModel(
            coordinator: coordinator,
            getAllContactsUseCase: appFactory.makeGetAll(),
            searchUseCase: appFactory.makeSearch()
        )
        let view = SearchView(viewModel: viewModel)
        return view
    }
}
