import Foundation

final class GetAllContactsUseCase {
    private let repository: ContactsServicesRepository
    
    init(repository: ContactsServicesRepository) {
        self.repository = repository
    }
    
    func execute() throws -> [Contact] {
        try repository.getAll()
    }
}
