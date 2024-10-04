import Foundation
import Contacts

struct LabeledValue: Identifiable, Hashable, Equatable {
    let id: String
    let label: String
    let value: String
}

extension LabeledValue {
    var labelType: LabeledValueLabelType {
        guard self.label == CNLabelHome else {
            return getLabelType(labelString: label)
        }

        if self.value.isPhoneNumber {
            return .phone
        } else if self.value.isEmail {
            return .email
        } else {
            return .address
        }
    }

    private func getLabelType(labelString: String) -> LabeledValueLabelType {
        switch labelString {
        case CNLabelPhoneNumberMobile, CNLabelPhoneNumberiPhone:
            return .mobile
        case CNLabelPhoneNumberMain:
            return .phone
        case CNLabelEmailiCloud:
            return .email
        case CNLabelURLAddressHomePage:
            return .url
        default:
            return .unknown
        }
    }
}
