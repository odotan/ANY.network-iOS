import Foundation

final class SearchNameUseCase {
    private let repository: ContactsServicesRepository
    
    init(repository: ContactsServicesRepository) {
        self.repository = repository
    }
    
    func search(name: String) async throws -> [Contact] {
        try repository.search(name: name)
    }
}
