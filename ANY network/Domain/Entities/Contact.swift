import Foundation

protocol Contact {
    var id: String { get }
    var givenName: String { get }
    var familyName: String { get }
//    var phoneNumbersArray: [String: String] { get }
//    var emailAdressesArray: [String: String] { get }
    var imageData: Data? { get }
    var imageDataAvailable: Bool { get }
}
