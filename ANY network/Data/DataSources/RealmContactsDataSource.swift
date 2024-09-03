import Foundation
import RealmSwift

final class RealmContactsDataSource {

    private let realmProvider = RealmProvider()
    
    @RealmActor
    func getStatus() async throws -> StatusObject? {
        guard let storage = await realmProvider.realm() else { throw RealmError.unknown }
        return storage.object(ofType: StatusObject.self, forPrimaryKey: "StatusObjectID")
    }
    
    @RealmActor @discardableResult
    func update(status value: Bool) async throws -> StatusObject {
        guard let storage = await realmProvider.realm() else { throw RealmError.unknown }
        guard let status = storage.object(ofType: StatusObject.self, forPrimaryKey: "StatusObjectID") else {
            let status = StatusObject(realmActivated: value)
            try storage.write {
                storage.add(status, update: .modified)
            }
            return status
        }
        
        status.realmActivated = value
        try storage.write {
            storage.add(status, update: .modified)
        }

        return status
    }

    @RealmActor
    func fetchContactList() async -> Results<ContactObject>? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.objects(ContactObject.self)
    }
    
    @RealmActor
    func fetchContact(id: String) async -> ContactObject? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.object(ofType: ContactObject.self, forPrimaryKey: id)
    }


    @RealmActor
    func saveContact(_ contactObject: ContactObject) async {
        guard let storage = await realmProvider.realm() else { return }

        storage.writeAsync {
            storage.add(contactObject, update: .all)
        }
    }
    
    @RealmActor
    func deleteAllContacts() async {
        guard let storage = await realmProvider.realm() else { return }

        storage.writeAsync {
            storage.delete(storage.objects(ContactObject.self))
        }
    }

    @RealmActor
    func deleteContact(id: String) async {
        guard
            let storage = await realmProvider.realm(),
            let contactObject = storage.object(ofType: ContactObject.self, forPrimaryKey: id)
        else { return }

        storage.writeAsync {
            storage.delete(contactObject)
        }
    }

    @RealmActor
    func addContact(_ contactObject: ContactObject, update: Bool = false) async {
        guard
            let storage = await realmProvider.realm(),
            !(update && storage.object(ofType: ContactObject.self, forPrimaryKey: contactObject.id) == nil)
        else { return }

        storage.writeAsync {
            storage.add(contactObject, update: .modified)
        }
    }
    
    @RealmActor
    func search(name: String) async throws -> [ContactObject] {
        guard let storage = await realmProvider.realm() else { return [] }
        return storage.objects(ContactObject.self).filter {
            if let givenName = $0.givenName, givenName.contains(name) {
                return true
            }
            
            if let familyName = $0.familyName, familyName.contains(name) {
                return true
            }
            
            return false
        }
    }
    
    @RealmActor
    func getFavorite() async throws -> Results<ContactObject>? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.objects(ContactObject.self).where { $0.isFavorite }
    }
    
    @RealmActor
    func checkIfFavorite(forRealmId id: String) async throws -> Bool {
        guard
            let storage = await realmProvider.realm(),
            let contact = storage.object(ofType: ContactObject.self, forPrimaryKey: id) else
        { throw RealmError.unknown }
        
        return contact.isFavorite
    }
    
    @RealmActor
    func toggleFavorite(forRealmId id: String) async throws -> Bool {
        guard
            let storage = await realmProvider.realm(),
            let contact = storage.object(ofType: ContactObject.self, forPrimaryKey: id) else
        { throw RealmError.unknown }
        
        contact.isFavorite.toggle()
        storage.writeAsync {
            storage.add(contact, update: .modified)
        }
        return contact.isFavorite
    }
}

// MARK: - Native Contacts
extension RealmContactsDataSource {
    @RealmActor
    func getFavoritesForNative() async throws -> Results<NativeFavoriteObject>? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.objects(NativeFavoriteObject.self)
    }
    
    @RealmActor
    func checkIfFavorite(forNativeId id: String) async throws -> Bool {
        guard let storage = await realmProvider.realm() else { throw RealmError.unknown }
        guard let _ = storage.object(ofType: NativeFavoriteObject.self, forPrimaryKey: id) else { return false }

        return true
    }
    
    @RealmActor
    func toggleFavorite(forNativeId id: String) async throws -> Bool {
        guard let storage = await realmProvider.realm() else { throw RealmError.unknown }

        if let object = storage.object(ofType: NativeFavoriteObject.self, forPrimaryKey: id) {
            storage.writeAsync {
                storage.delete(object)
            }
            return false
        } else {
            storage.writeAsync {
                storage.add(NativeFavoriteObject(nativeId: id))
            }
            
            return true
        }
    }
    
    @RealmActor
    func create(contact contactT: Contact) async throws -> ContactObject {
        guard let storage = await realmProvider.realm() else {
            throw RealmError.unknown }

        let contact = ContactObject(contactT)
        
        storage.writeAsync {
            storage.add(contact)
        }
        
        return contact
    }
    
    @RealmActor
    func update(contact contactT: Contact) async throws -> ContactObject {
        guard
            let storage = await realmProvider.realm(),
            let contact = storage.object(ofType: ContactObject.self, forPrimaryKey: contactT.id) else
        { throw RealmError.unknown }
        
        let temp = ContactObject(contactT)
        temp.id = contact.id
        
        storage.writeAsync {
            storage.add(temp, update: .modified)
        }
        return contact
    }
}

enum RealmError: Error {
    case unknown
}
