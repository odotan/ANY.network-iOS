import Foundation

final class CheckIfRealmContainsContacts {
    private let contactsRepository: ContactsRepository
    
    init(contactsRepository: ContactsRepository) {
        self.contactsRepository = contactsRepository
    }
    
    func execute() async throws -> Bool {
        try await contactsRepository.checkIfRealmContainsContacts()
    }
}
