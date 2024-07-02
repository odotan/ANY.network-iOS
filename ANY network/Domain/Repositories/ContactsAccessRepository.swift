import Foundation

protocol ContactsAccessRepository {
    var status: ContactsServicesStatus { get }
    func requestAccess() async throws
}
