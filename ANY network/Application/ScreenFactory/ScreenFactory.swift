import Foundation

final class ScreenFactory: OnboardingCoordinatorFactory, 
                            MainCoordinatorFactory {

    private let appFactory: AppFactory
    
    init(appFactory: AppFactory) {
        self.appFactory = appFactory
    }
}

extension ScreenFactory: IntroFactory {
    func makeIntro(coordinator: OnboardingCoordinatorProtocol) -> IntroView {
        let viewModel = IntroViewModel(coordinator: coordinator)
        let view = IntroView(viewModel: viewModel)

        return view
    }
}


extension ScreenFactory: ContactsPermissionFactory {
    func makeContactsPermission(coordinator: OnboardingCoordinatorProtocol) -> ContactsPermissionView {
        let viewModel = ContactsPermissionViewModel(
            coordinator: coordinator,
            getRequestAccessUseCase: appFactory.makeRequestAccess()
        )
        let view = ContactsPermissionView(viewModel: viewModel)

        return view
    }
}

extension ScreenFactory: ConnectFactory {
    func makeConnect(coordinator: any OnboardingCoordinatorProtocol) -> ConnectView {
        let viewModel = ConnectViewModel(coordinator: coordinator)
        let view = ConnectView(viewModel: viewModel)
        
        return view
    }
}

extension ScreenFactory: HomeFactory {
    func makeHome(coordinator: MainCoordinatorProtocol) -> HomeView {
        let viewModel = HomeViewModel(
            coordinator: coordinator,
            getAllContactsUseCase: appFactory.makeGetAll()
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
