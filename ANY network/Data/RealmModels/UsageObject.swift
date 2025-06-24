import Foundation
import RealmSwift

class UsageObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var contact: ContactObject?
    @Persisted var date: Date
    
    convenience init(_ usage: Usage) {
        self.init()

        self.id = usage.id
        self.date = usage.date

        if let usageContact = usage.contact {
            self.contact = ContactObject(usageContact)
        }
    }
    
    func asUsage() -> Usage {
        Usage(
            id: id,
            contact: contact?.asContact(),
            date: date
        )
    }
}
