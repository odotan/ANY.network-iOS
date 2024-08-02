import Foundation

final class ContactsRepositoryImplementation {
    
    private var contacts: [Contact] = [Contact]()
    
    private let realmDataSource: RealmContactsDataSource
    private let nativeDataSource: NativeContactsDataSource
    
    private var all: [Contact]?
    
    init(realmDataSource: RealmContactsDataSource, nativeDataSource: NativeContactsDataSource) {
        self.realmDataSource = realmDataSource
        self.nativeDataSource = nativeDataSource
    }
}

extension ContactsRepositoryImplementation: ContactsRepository {
    var status: ContactsServicesStatus {
        nativeDataSource.status
    }
    
    func requestAccess() async throws {
        try await nativeDataSource.requestAccess()
    }
    
    @RealmActor
    func getAll() async throws -> [Contact] {
        if let all = all {
            return all
        }

        if status == .authorized {
            all = try await nativeDataSource.getAll().asContacts()
        } else if let contacts = await realmDataSource.fetchContactList() {
            all = contacts.asContact()
        }

        return all ?? []
    }

    @RealmActor
    func getContact(withIdentifier identifier: String) async throws -> Contact? {
        if status == .authorized {
            return try nativeDataSource.getContact(withIdentifier: identifier)?.asContact()
        }

        return await realmDataSource.fetchContact(id: identifier)?.asContact()
    }
    
    @RealmActor
    func search(name: String) async throws -> [Contact] {
        if status == .authorized {
            return try nativeDataSource.search(name: name).compactMap { $0.asContact() }
        }
        
        return try await realmDataSource.search(name: name).compactMap { $0.asContact() }
    }
    
    @RealmActor
    func getFavoriteContacts() async throws -> [Contact] {
        if status == .authorized {
            guard let favoriteIdsObjects = try await realmDataSource.getFavoritesForNative() else { return [] }

            var favorites = [Contact]()
            for idObj in favoriteIdsObjects {
                let contact = try nativeDataSource.getContact(withIdentifier: idObj.nativeId)!.asContact()
                favorites.append(contact)
            }
            return favorites
        }
        
        guard let favorites = try await realmDataSource.getFavorite() else { return [] }
        return favorites.compactMap { $0.asContact() }
    }
    
    @RealmActor
    func toggleFavorite(contactId: String) async throws {
        if status == .authorized {
            try await realmDataSource.toggleFavorite(forNativeId: contactId)
        } else {
            try await realmDataSource.toggleFavorite(forRealmId: contactId)
        }
    }
}

enum ContactRepositoryError: Error {
    case custom
}
