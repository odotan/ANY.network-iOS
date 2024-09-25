import Foundation

protocol ContactsRepository {
    func getStatus() async throws -> ContactServiceType
    func update(status: ContactServiceType) async throws
    func requestAccess() async throws
    func getAll() async throws -> [Contact]
    func getContact(withIdentifier identifier: String) async throws -> Contact?
    func search(name: String) async throws -> [Contact]
    func search(term: String) async throws -> [Contact]
    func createEdit(contact: Contact) async throws -> Contact

    // Favorites
    func getFavoriteContacts() async throws -> [Contact]
    func checkIfFavorite(contactId: String) async throws -> Bool
    func toggleFavorite(contactId: String) async throws -> Bool
}
