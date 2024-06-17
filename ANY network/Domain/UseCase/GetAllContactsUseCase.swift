import Foundation

final class GetAllContactsUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    func execute() throws -> [Contact] {
        try repository.getAll()
    }
}
