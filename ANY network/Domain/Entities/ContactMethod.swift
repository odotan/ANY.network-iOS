import Foundation
import SwiftUI

protocol ContactMethod: Identifiable, Equatable {
    var id: String { get }
    var value: String { get }
    var image: ImageResource { get }
}

enum ContactMethodType {
    case phoneNumbers
    case emailAddresses
    case postalAddresses
    case urlAddresses
    case socialProfiles
    case instantMessageAddresses
}
