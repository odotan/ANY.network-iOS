import Foundation

struct Usage: Equatable, Hashable, Identifiable {
    let id: String
    let contact: Contact?
    let date: Date
}
