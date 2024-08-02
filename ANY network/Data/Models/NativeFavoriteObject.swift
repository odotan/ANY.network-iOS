import Foundation
import RealmSwift

class NativeFavoriteObject: Object {
    @Persisted(primaryKey: true) var nativeId: String
    
    convenience init(nativeId: String) {
        self.init()
        self.nativeId = nativeId
    }
}
