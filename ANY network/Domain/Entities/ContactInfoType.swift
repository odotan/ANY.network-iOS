import SwiftUI
import Contacts

protocol ContactInfoType: Hashable {
    var label: String { get }
    var title: String { get }
    var keyboardType: UIKeyboardType { get }
    var prompt: String { get }

    static var allCases: [Self] { get }

    static func getValue(label: String) -> Self?
}

enum PhoneNumberType: ContactInfoType {
    case mobile, home, work, school, iPhone, appleWatch, main, homeFax, workFax, pager, other

    var label: String {
        switch self {
        case .mobile:
            CNLabelPhoneNumberMobile
        case .home:
            CNLabelHome
        case .work:
            CNLabelWork
        case .school:
            CNLabelSchool
        case .iPhone:
            CNLabelPhoneNumberiPhone
        case .appleWatch:
            CNLabelPhoneNumberAppleWatch
        case .main:
            CNLabelPhoneNumberMain
        case .homeFax:
            CNLabelPhoneNumberHomeFax
        case .workFax:
            CNLabelPhoneNumberWorkFax
        case .pager:
            CNLabelPhoneNumberPager
        case .other:
            CNLabelOther
        }
    }

    var title: String {
        switch self {
        case .mobile:
            "Mobile"
        case .home:
            "Home"
        case .work:
            "Work"
        case .school:
            "School"
        case .iPhone:
            "iPhone"
        case .appleWatch:
            "Apple Watch"
        case .main:
            "Main"
        case .homeFax:
            "Home Fax"
        case .workFax:
            "Work Fax"
        case .pager:
            "Pager"
        case .other:
            "Other"
        }
    }

    var keyboardType: UIKeyboardType { .phonePad }
    var prompt: String { "Phone number" }

    static let allCases: [PhoneNumberType] = [.mobile, .home, .work, .school, .iPhone, .appleWatch, .main, .homeFax, .workFax, .pager, .other]

    static func getValue(label: String) -> PhoneNumberType? {
        PhoneNumberType.allCases.first(where: { $0.label == label })
    }
}

enum PostalAddressType: ContactInfoType {
    case home, work, school, other

    var label: String {
        switch self {
        case .home:
            CNLabelHome
        case .work:
            CNLabelWork
        case .school:
            CNLabelSchool
        case .other:
            CNLabelOther
        }
    }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .work:
            "Work"
        case .school:
            "School"
        case .other:
            "Other"
        }
    }

    var keyboardType: UIKeyboardType { .default }
    var prompt: String { "Postal Address" }

    static let allCases: [PostalAddressType] = [.home, .work, .school, .other]

    static func getValue(label: String) -> PostalAddressType? {
        PostalAddressType.allCases.first(where: { $0.label == label })
    }
}

enum EmailAddressType: ContactInfoType {
    case home, work, school, iCloud, other

    var label: String {
        switch self {
        case .home:
            CNLabelHome
        case .work:
            CNLabelWork
        case .school:
            CNLabelSchool
        case .iCloud:
            CNLabelEmailiCloud
        case .other:
            CNLabelOther
        }
    }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .work:
            "Work"
        case .school:
            "School"
        case .iCloud:
            "iCloud"
        case .other:
            "Other"
        }
    }

    var keyboardType: UIKeyboardType { .emailAddress }
    var prompt: String { "Email Address" }

    static let allCases: [EmailAddressType] = [.home, .work, .school, .iCloud, .other]

    static func getValue(label: String) -> EmailAddressType? {
        EmailAddressType.allCases.first(where: { $0.label == label })
    }
}

enum URLAddressType: ContactInfoType {
    case homePage, home, work, school, other

    var label: String {
        switch self {
        case .homePage:
            CNLabelURLAddressHomePage
        case .home:
            CNLabelHome
        case .work:
            CNLabelWork
        case .school:
            CNLabelSchool
        case .other:
            CNLabelOther
        }
    }

    var title: String {
        switch self {
        case .homePage:
            "Homepage"
        case .home:
            "Home"
        case .work:
            "Work"
        case .school:
            "School"
        case .other:
            "Other"
        }
    }

    var keyboardType: UIKeyboardType { .URL }
    var prompt: String { "URL Address" }

    static let allCases: [URLAddressType] = [.homePage, .home, .work, .school, .other]

    static func getValue(label: String) -> URLAddressType? {
        URLAddressType.allCases.first(where: { $0.label == label })
    }
}

enum UnknownType: ContactInfoType {
    case unknown
    var label: String { "Unknown" }
    var title: String { "Unknown" }
    var keyboardType: UIKeyboardType { .default }
    var prompt: String { "Unknown" }
    static let allCases: [UnknownType] = [.unknown]
    static func getValue(label: String) -> UnknownType? { return .unknown }
}

struct ContactInfoTypeCreator {
    func getType(label: String, type string: String?) -> (any ContactInfoType)? {
        switch string {
        case PhoneNumberType.home.prompt:
            return PhoneNumberType.getValue(label: label)
        case PostalAddressType.home.prompt:
            return PostalAddressType.getValue(label: label)
        case EmailAddressType.home.prompt:
            return EmailAddressType.getValue(label: label)
        case URLAddressType.home.prompt:
            return URLAddressType.getValue(label: label)
        default:
            return nil
        }
    }
}
