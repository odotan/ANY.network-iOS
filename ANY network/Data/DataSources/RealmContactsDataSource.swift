import Foundation
import RealmSwift

final class RealmContactsDataSource {

    private let realmProvider = RealmProvider()

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
    func toggleFavorite(forRealmId id: String) async throws {
        guard
            let storage = await realmProvider.realm(),
            let contact = storage.object(ofType: ContactObject.self, forPrimaryKey: id) else
        { return }
        
        contact.isFavorite.toggle()
        storage.writeAsync {
            storage.add(contact, update: .modified)
        }
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
    func toggleFavorite(forNativeId id: String) async throws {
        guard let storage = await realmProvider.realm() else { return }

        if let object = storage.object(ofType: NativeFavoriteObject.self, forPrimaryKey: id) {
            storage.writeAsync {
                storage.delete(object)
            }
        } else {
            storage.writeAsync {
                storage.add(NativeFavoriteObject(nativeId: id))
            }
        }
    }
}
