import Foundation
import RealmSwift

class LabeledValueObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var value: String
    @Persisted var label: String
    
    convenience init(_ labeledValue: LabeledValue) {
        self.init()
        
        self.value = labeledValue.value
        self.label = labeledValue.label
    }
    
    func asLabeledValue() -> LabeledValue {
        return LabeledValue(
            id: id,
            label: label,
            value: value
        )
    }
}

extension List where Element: LabeledValueObject {
    func asLabeledValues() -> [LabeledValue] {
        compactMap { $0.asLabeledValue() }
    }
}
