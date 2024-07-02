import Foundation

final class AppFactory {
    private lazy var contactsService = ContactsService()
}

extension AppFactory {
    func makeContactsStatus() -> GetContactsStatusUseCase {
        GetContactsStatusUseCase(repository: contactsService)
    }

    func makeRequestAccess() -> GetRequestAccessUseCase {
        GetRequestAccessUseCase(repository: contactsService)
    }
    
    func makeGetContact(withIdentifier identifier: String) -> GetContactUseCase {
        GetContactUseCase(repository: contactsService, identifier: identifier)
    }
    
    func makeGetAll() -> GetAllContactsUseCase {
        GetAllContactsUseCase(repository: contactsService)
    }
    
    func makeSearch() -> SearchNameUseCase {
        SearchNameUseCase(repository: contactsService)
    }
}
