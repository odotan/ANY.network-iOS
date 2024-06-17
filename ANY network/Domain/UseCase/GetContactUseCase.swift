import Foundation

final class GetContactUseCase {
    private let repository: ContactsRepository
    private let identifier: String
    
    init(repository: ContactsRepository, identifier: String) {
        self.repository = repository
        self.identifier = identifier
    }
    
    func execute() throws -> Contact {
        try repository.getContact(withIdentifier: identifier)
    }
}
