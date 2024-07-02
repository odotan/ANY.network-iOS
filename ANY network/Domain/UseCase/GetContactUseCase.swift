import Foundation

final class GetContactUseCase {
    private let repository: ContactsServicesRepository
    private let identifier: String
    
    init(repository: ContactsServicesRepository, identifier: String) {
        self.repository = repository
        self.identifier = identifier
    }
    
    func execute() throws -> Contact {
        try repository.getContact(withIdentifier: identifier)
    }
}
