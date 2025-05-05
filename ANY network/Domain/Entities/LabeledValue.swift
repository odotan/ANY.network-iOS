import Foundation
import Contacts

struct LabeledValue: Identifiable {
    let id: String
    let label: String
    let value: String
    let infoType: (any ContactInfoType)?

    init(id: String, label: String, value: String, infoType: (any ContactInfoType)? = nil) {
        self.id = id
        self.label = label
        self.value = value
        self.infoType = infoType
    }
}

extension LabeledValue: Equatable, Hashable {
    static func == (lhs: LabeledValue, rhs: LabeledValue) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
