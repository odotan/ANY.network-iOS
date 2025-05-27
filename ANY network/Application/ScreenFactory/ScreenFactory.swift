import Foundation
import SwiftUI

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
            getRequestAccessUseCase: appFactory.makeRequestAccess(),
            checkIfRealmContainsContacts: appFactory.makeCheckIfRealmContainsContacts(),
            mergeRealmContactsUseCase: appFactory.makeMergeRealmContactsUseCase(),
            fetchInteractionsUseCase: appFactory.makeFetchInteractionsUseCase(),
            interactWithContactUseCase: appFactory.makeInteractWithContactUseCase(),
            deleteInteractionUseCase: appFactory.makeDeleteInteractionUseCase(),
            getIsMeContactUseCase: appFactory.makeGetIsMeUseCase()
        )

        let view = HomeView(viewModel: viewModel)

        return view
    }
}

extension ScreenFactory: MyProfileFactory {
    
    @MainActor func makeMyProfile(coordinator: MainCoordinatorProtocol, onDismiss: @escaping () -> Void) -> MyProfileView {
        let viewModel = MyProfileViewModel(
            coordinator: coordinator,
            getAllContactsUseCase: appFactory.makeGetAll(),
            searchUseCase: appFactory.makeSearch(),
            setIsMeContactUseCase: appFactory.makeSetIsMeContactUseCase(),
            onDismiss: onDismiss
        )
        let view = MyProfileView(viewModel: viewModel)
        
        return view
    }
}

extension ScreenFactory: DetailsFactory {
    func makeDetails(
        contact: Contact,
        isNew: Bool,
        onContactChangeEvent: @escaping (ContactChangeEvent) -> Void,
        coordinator: MainCoordinatorProtocol
    ) -> DetailsView {
        let viewModel = DetailsViewModel(
            contact: contact,
            isNew: isNew,
            coordinator: coordinator,
            toggleFavoriteUseCase: appFactory.makeToggleFavorite(),
            checkIfFavoriteUseCase: appFactory.makeCheckIfFavorite(),
            createEditContactUseCase: appFactory.makeCreateEditContactUseCase(),
            deleteContactUseCase: appFactory.makeDeleteContactUseCase(),
            interactWithContactUseCase: appFactory.makeInteractWithContactUseCase(),
            onContactChangeEvent: onContactChangeEvent
        )
        let view = DetailsView(viewModel: viewModel)
        
        return view
    }
}

extension ScreenFactory: SearchFactory {
    func makeSearch(
        onContactChangeEvent: @escaping (ContactChangeEvent) -> Void,
        coordinator: MainCoordinatorProtocol
    ) -> SearchView {
        let viewModel = SearchViewModel(
            coordinator: coordinator,
            getAllContactsUseCase: appFactory.makeGetAll(),
            searchUseCase: appFactory.makeSearch(),
            interactWithContactUseCase: appFactory.makeInteractWithContactUseCase(),
            onContactChangeEvent: onContactChangeEvent
        )
        let view = SearchView(viewModel: viewModel)
        return view
    }
}

extension ScreenFactory: ConnectFactory {
    func makeConnect(contact: Contact, coordinator: any MainCoordinatorProtocol) -> ConnectView {
        let viewmodel = ConnectViewModel(contact: contact, coordinator: coordinator)
        let view = ConnectView(viewModel: viewmodel)
        return view
    }
}

extension ScreenFactory: ConnectNetworkSignUpFactory {
    func makeConnectNetworkSignUp(networkItem: NetworkItem, contact: Contact, coordinator: any MainCoordinatorProtocol) -> ConnectNetworkSignUpView {
        let viewmodel = ConnectNetworkSignUpViewModel(
            networkItem: networkItem,
            contact: contact,
            coordinator: coordinator,
            smsAuthenticatorUseCase: appFactory.makeSmsSendUseCase(),
            facebookLoginUseCase: appFactory.makeFacebookLoginUseCase(),
            telegramLoginUseCase: appFactory.makeTelegramLoginUseCase(),
            emailLoginUseCase: appFactory.makeSendEmailUseCase()
        )
        let view = ConnectNetworkSignUpView(viewModel: viewmodel)
        return view
    }
}

extension ScreenFactory: ConnectNetworkConfirmationFactory {
    func makeConnectNetworkConfirmation(networkItem: NetworkItem, coordinator: any MainCoordinatorProtocol) -> ConnectNetworkConfirmationView {
        let viewmodel = ConnectNetworkConfirmationViewModel(networkItem: networkItem, coordinator: coordinator)
        let view = ConnectNetworkConfirmationView(viewModel: viewmodel)
        return view
    }
}

extension ScreenFactory: RequestNetworkFactory {
    func makeRequestNetwork(contact: Contact, coordinator: any MainCoordinatorProtocol) -> RequestNetworkView {
        let viewmodel = RequestNetworkViewModel(contact: contact, coordinator: coordinator)
        let view = RequestNetworkView(viewModel: viewmodel)
        return view
    }
}

extension ScreenFactory: HiUFactory {
    func makeHiU(coordinator: MainCoordinatorProtocol) -> HiUHomeView {
        let viewModel = HiUHomeViewModel(coordinator: coordinator)
        let view = HiUHomeView(viewModel: viewModel)
        return view
    }
}
