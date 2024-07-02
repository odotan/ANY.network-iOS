import Foundation

struct Contact: Hashable, Equatable, Identifiable {
    let id: String
    let givenName: String
    let familyName: String
    let imageData: Data?
    let imageDataAvailable: Bool
}

protocol AnyContact: Hashable, Equatable {
    var id: String { get }
    var givenName: String { get }
    var familyName: String { get }
//    var phoneNumbersArray: [String: String] { get }
//    var emailAdressesArray: [String: String] { get }
    var imageData: Data? { get }
    var imageDataAvailable: Bool { get }
    
    func asContact() -> Contact
}

extension AnyContact {
    func asContact() -> Contact {
        Contact(
            id: id,
            givenName: givenName,
            familyName: familyName,
            imageData: imageData,
            imageDataAvailable: imageDataAvailable
        )
    }
}

extension Array where Element: AnyContact {
    func asContacts() -> [Contact] {
        self.compactMap { $0.asContact() }
    }
}
