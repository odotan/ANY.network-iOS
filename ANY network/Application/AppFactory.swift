import Foundation

final class AppFactory {
    private lazy var hepticService = HepticService()

    private lazy var contactsRepository: ContactsRepositoryImplementation = {
        let realmDataSource = RealmContactsDataSource()
        let nativeDataSource = NativeContactsDataSource()
        return ContactsRepositoryImplementation(realmDataSource: realmDataSource, nativeDataSource: nativeDataSource)
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
    
    func makeSearch() -> SearchNameUseCase {
        SearchNameUseCase(repository: contactsRepository)
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
}
