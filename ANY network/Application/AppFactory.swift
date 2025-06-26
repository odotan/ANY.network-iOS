import Foundation

final class AppFactory {
    private lazy var hepticService = HapticService()

    private lazy var contactsRepository: ContactsRepositoryImplementation = {
        let realmDataSource = RealmContactsDataSource()
        let nativeDataSource = NativeContactsDataSource()
        return ContactsRepositoryImplementation(realmDataSource: realmDataSource, nativeDataSource: nativeDataSource)
    }()
    
    private lazy var networkAuthenticationRepository: NetworkAuthenticationRepositoryImplementation = {
        let smsAuthenticator = SMSNetworkAuthentication()
        let facebookAuthenticator = FacebookNetworkAuthentication()
        let telegramAuthenticator = TelegramNetworkAuthentication()
        let emailAuthenticator = EmailNetworkAuthentication()

        return NetworkAuthenticationRepositoryImplementation(
            smsAuthenticator: smsAuthenticator,
            facebookAuthenticator: facebookAuthenticator,
            telegramAuthenticator: telegramAuthenticator,
            emailAuthenticator: emailAuthenticator
        )
    }()
    
    private lazy var xmtpRepository: XMTPRepositoryImplementation = {
        let xmtpManager = XMTPManager()
        return XMTPRepositoryImplementation(xmtpManager: xmtpManager)
    }()

    private lazy var firebaseRepository: FirebaseRepositoryImplementation = {
        let firebaseManager = FirebaseManager()
        return FirebaseRepositoryImplementation(firebaseManager: firebaseManager)
    }()
}

extension AppFactory {
    func makeContactsStatus() -> ContactsStatusUseCase {
        ContactsStatusUseCase(repository: contactsRepository)
    }

    func makeRequestAccess() -> GetRequestAccessUseCase {
        GetRequestAccessUseCase(repository: contactsRepository)
    }
    
    func makeGetContact() -> GetContactUseCase {
        GetContactUseCase(repository: contactsRepository)
    }
    
    func makeGetAll() -> GetAllContactsUseCase {
        GetAllContactsUseCase(repository: contactsRepository)
    }
    
    func makeSearch() -> SearchInContactUseCase {
        SearchInContactUseCase(repository: contactsRepository)
    }
    
    func makeToggleFavorite() -> ToggleFavoriteUseCase {
        ToggleFavoriteUseCase(repository: contactsRepository)
    }
    
    func makeGetFavoriteContacts() -> GetFavoriteContactsUseCase {
        GetFavoriteContactsUseCase(repository: contactsRepository)
    }
    
    func makeCheckIfFavorite() -> CheckIfFavoriteUseCase {
        CheckIfFavoriteUseCase(repository: contactsRepository)
    }
    
    func makeCreateEditContactUseCase() -> CreateEditContactUseCase {
        CreateEditContactUseCase(repository: contactsRepository)
    }

    func makeDeleteContactUseCase() -> DeleteContactUseCase {
        DeleteContactUseCase(repository: contactsRepository)
    }

    func makeFetchInteractionsUseCase() -> FetchInteractionsUseCase {
        FetchInteractionsUseCase(repository: contactsRepository)
    }

    func makeFetchInteractionUseCase() -> FetchInteractionUseCase {
        FetchInteractionUseCase(repository: contactsRepository)
    }

    func makeInteractWithContactUseCase() -> InteractWithContactUseCase {
        InteractWithContactUseCase(repository: contactsRepository)
    }

    func makeDeleteInteractionUseCase() -> DeleteInteractionUseCase {
        DeleteInteractionUseCase(repository: contactsRepository)
    }
    
    func makeGetIsMeUseCase() -> GetIsMeContactUseCase {
        GetIsMeContactUseCase(repository: contactsRepository)
    }
    
    func makeSetIsMeContactUseCase() -> SetIsMeContactUseCase {
        SetIsMeContactUseCase(repository: contactsRepository)
    }
    
    func makeCheckIfRealmContainsContacts() -> CheckIfRealmContainsContacts {
        CheckIfRealmContainsContacts(contactsRepository: contactsRepository)
    }
    
    func makeMergeRealmContactsUseCase() -> MergeRealmContactsUseCase {
        MergeRealmContactsUseCase(repository: contactsRepository)
    }
    
    func makeSmsSendUseCase() -> SMSSendCodeUseCase {
        SMSSendCodeUseCase(networkRepository: networkAuthenticationRepository)
    }
    
    func makeFacebookLoginUseCase() -> FacebookLoginUseCase {
        FacebookLoginUseCase(networkRepository: networkAuthenticationRepository)
    }
    
    func makeTelegramLoginUseCase() -> TelegramLoginUseCase {
        TelegramLoginUseCase(networkRepository: networkAuthenticationRepository)
    }
    
    func makeSendEmailUseCase() -> EmailLoginUseCase {
        EmailLoginUseCase(networkRepository: networkAuthenticationRepository)
    }
    
    func makeCreateXMTPClientUseCase() -> CreateXMTPClientUseCase {
        CreateXMTPClientUseCase(xmtpRepository: xmtpRepository)
    }
    
    func makeXMTPConversationUseCase() -> XMTPConversationUseCase {
        XMTPConversationUseCase(xmtpRepository: xmtpRepository)
    }

    func makeStoreXMTPUserUseCase() -> StoreXMTPUserUseCase {
        StoreXMTPUserUseCase(repository: firebaseRepository)
    }

    func makeFetchAllXMTPUsersUseCase() -> FetchAllXMTPUsersUseCase {
        FetchAllXMTPUsersUseCase(repository: firebaseRepository)
    }
}
