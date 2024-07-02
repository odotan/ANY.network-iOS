import Foundation

final class GetContactsStatusUseCase {
    private let repository: ContactsAccessRepository
    
    init(repository: ContactsAccessRepository) {
        self.repository = repository
    }
    
    var status: ContactsServicesStatus {
        repository.status
    }
}
