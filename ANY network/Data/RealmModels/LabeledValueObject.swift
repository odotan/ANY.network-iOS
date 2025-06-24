import Foundation
import RealmSwift

class LabeledValueObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var value: String
    @Persisted var label: String
    @Persisted var infoType: String?

    convenience init(_ labeledValue: LabeledValue) {
        self.init()
        
        self.id = labeledValue.id
        self.value = labeledValue.value
        self.label = labeledValue.label
        self.infoType = labeledValue.infoType?.prompt
    }
    
    func asLabeledValue() -> LabeledValue {
        return LabeledValue(
            id: id,
            label: label,
            value: value,
            infoType: ContactInfoTypeCreator().getType(label: label, type: infoType)
        )
    }
}

extension List where Element: LabeledValueObject {
    func asLabeledValues() -> [LabeledValue] {
        compactMap { $0.asLabeledValue() }
    }
}
