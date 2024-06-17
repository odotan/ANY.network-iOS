import Foundation

final class GetContactsStatusUseCase {
    private let repository: ContactsRepository
    
    init(repository: ContactsRepository) {
        self.repository = repository
    }
    
    var status: ContactsServicesStatus {
        repository.status
    }
}
