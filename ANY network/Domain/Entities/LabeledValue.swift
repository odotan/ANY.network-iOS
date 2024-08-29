import Foundation

struct LabeledValue: Identifiable, Hashable, Equatable {
    let id: String
    let label: String
    let value: String
}

extension LabeledValue {
    var labelType: LabeledValueLabelType {
        return LabeledValueLabelType.allCases.first(where: { $0.value == self.label }) ?? .unknown
    }
}
