import Foundation

struct LabeledValue: Identifiable, Hashable, Equatable {
    let id: String
    let label: String
    let value: String
}

extension LabeledValue {
    var labelType: LabeledValueLabelType {
        guard self.label == LabeledValueLabelType.address.value else { // If label is _$!<Home>!$_
            return LabeledValueLabelType.allCases.first(where: { $0.value == self.label }) ?? .unknown
        }

        if self.value.isPhoneNumber {
            return .phone
        } else if self.value.isEmail {
            return .email
        } else {
            return .address
        }
    }
}
