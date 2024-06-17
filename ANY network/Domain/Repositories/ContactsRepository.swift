import Foundation

protocol ContactsRepository {
    var status: ContactsServicesStatus { get }
    func requestAccess() async throws
    func getAll() throws -> [Contact]
    func getContact(withIdentifier identifier: String) throws -> Contact
}
