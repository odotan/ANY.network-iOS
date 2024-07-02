import Foundation

protocol ContactsServicesRepository {
    func getAll() throws -> [Contact]
    func getContact(withIdentifier identifier: String) throws -> Contact
    func search(name: String) throws -> [Contact]
}
