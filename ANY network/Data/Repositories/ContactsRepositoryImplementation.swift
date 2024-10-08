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
    @RealmActor
    func getStatus() async throws -> ContactServiceType {
        if let realmStatus = try await realmDataSource.getStatus(), realmStatus.realmActivated {
            return .realm
        }

        if nativeDataSource.status == .authorized {
            return .native
        }
        
        if nativeDataSource.status == .denied {
            return .realm
        }

        return .notDetermined
    }
    
    @RealmActor
    func update(status: ContactServiceType) async throws {
        guard status == .realm else { throw ContactRepositoryError.status }
        try await realmDataSource.update(status: true)
    }
    
    func requestAccess() async throws {
        try await nativeDataSource.requestAccess()
    }
    
    @RealmActor @discardableResult
    func getAll() async throws -> [Contact] {
        let status = try await getStatus()
        
        if let all = all, !all.isEmpty {
            return all
        }

        if status == .native {
            all = try await nativeDataSource.getAll().asContacts()
        } else if let contacts = await realmDataSource.fetchContactList() {
            all = contacts.asContact()
        }

        return all ?? []
    }

    @RealmActor
    func getContact(withIdentifier identifier: String) async throws -> Contact? {
        let status = try await getStatus()

        if status == .native {
            return try nativeDataSource.getContact(withIdentifier: identifier)?.asContact()
        }

        return await realmDataSource.fetchContact(id: identifier)?.asContact()
    }
    
    /// Searches for `Contact` objects whose name contain the specified string
    @RealmActor
    func search(name: String) async throws -> [Contact] {
        let status = try await getStatus()
        
        if status == .native {
            return try nativeDataSource.search(name: name).compactMap { $0.asContact() }
        }

        return try await realmDataSource.search(name: name).compactMap { $0.asContact() }
    }

    /// Searches for `Contact` objects whose properties contain the specified string
    @RealmActor
    func search(term: String) async throws -> [Contact] {
        let status = try await getStatus()
        
        if status == .native {
            return try nativeDataSource.search(term: term).compactMap { $0.asContact() }
        }

        return try await realmDataSource.search(term: term).compactMap { $0.asContact() }
    }

    @RealmActor
    func getFavoriteContacts() async throws -> [Contact] {
        let status = try await getStatus()

        if status == .native {
            guard let favoriteIdsObjects = try await realmDataSource.getFavoritesForNative() else { return [] }

            var favoritesArray = [Contact]()
            for idObj in favoriteIdsObjects {
                let contact = try nativeDataSource.getContact(withIdentifier: idObj.nativeId)!.asContact()
                favoritesArray.append(contact)
            }
            
            return favoritesArray
        }
        
        guard let favoritesArray = try await realmDataSource.getFavorite() else { return [] }
        return favoritesArray.compactMap { $0.asContact() }
    }
    
    @RealmActor
    func checkIfFavorite(contactId: String) async throws -> Bool {
        let status = try await getStatus()

        if status == .native {
            return try await realmDataSource.checkIfFavorite(forNativeId: contactId)
        } else {
            return try await realmDataSource.checkIfFavorite(forRealmId: contactId)
        }
    }
    
    @RealmActor
    func toggleFavorite(contactId: String) async throws -> Bool {
        let status = try await getStatus()
        
        if status == .native {
            return try await realmDataSource.toggleFavorite(forNativeId: contactId)
        } else {
            return try await realmDataSource.toggleFavorite(forRealmId: contactId)
        }
    }
    
    @RealmActor
    func createEdit(contact: Contact) async throws -> Contact {
        var new: Contact!
        let status = try await getStatus()
        
        // Create Contact
        if contact.id.isEmpty {
            if status == .native {
                new = try await nativeDataSource.create(contact: contact).asContact()
            } else {
                new = try await realmDataSource.create(contact: contact).asContact()
            }
        } else { // Update Contact
            if status == .native {
                new = try await nativeDataSource.update(contact: contact).asContact()
            } else {
                new = try await realmDataSource.update(contact: contact).asContact()
            }
        }
        
        if let index = all?.firstIndex(where: { new.id == $0.id }) {
            all?[index] = new
        } else {
            all = nil
            try await getAll()
        }
        
        return new
    }

}

enum ContactRepositoryError: Error {
    case status
    case custom
}

enum ContactServiceType {
    case notDetermined
    case native
    case realm
}
