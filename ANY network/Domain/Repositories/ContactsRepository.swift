import Foundation

protocol ContactsRepository {
    var status: ContactsServicesStatus { get }
    func requestAccess() async throws
    func getAll() async throws -> [Contact]
    func getContact(withIdentifier identifier: String) async throws -> Contact?
    func search(name: String) async throws -> [Contact]
    
    // Favorites
    func getFavoriteContacts() async throws -> [Contact]
    func checkIfFavorite(contactId: String) async throws -> Bool
    func toggleFavorite(contactId: String) async throws -> Bool
}
