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
    func deleteContact(id: String) async throws
    func checkIfRealmContainsContacts() async throws -> Bool
    func mergeRealmIntoNativeContacts() async throws

    // Favorites
    func getFavoriteContacts() async throws -> [Contact]
    func getIsMeContact() async throws -> Contact?
    func setIsMe(contactId: String) async throws
    func checkIfFavorite(contactId: String) async throws -> Bool
    func toggleFavorite(contactId: String) async throws -> Bool

    // Interactions
    func fetchInteractions() async throws -> [ContactInteraction]
    func fetchInteraction(id: String) async throws -> ContactInteraction?
    func saveInteraction(interaction: ContactInteraction, type: InteractionActionType) async throws
    func deleteInteraction(id: String) async throws
}
