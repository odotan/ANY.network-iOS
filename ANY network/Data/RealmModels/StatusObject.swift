import Foundation
import RealmSwift

class StatusObject: Object {
    @Persisted(primaryKey: true) var id: String = "StatusObjectID"
    @Persisted var realmActivated: Bool
    
    convenience init(realmActivated: Bool) {
        self.init()
        self.realmActivated = realmActivated
    }
}
