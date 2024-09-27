import Foundation
import SwiftUI

struct PhoneNumber: ContactMethod {
    let id: String
    let value: String
    let image: ImageResource

    init(id: String = UUID().uuidString, value: String) {
        self.id = id
        self.value = value
        self.image = .phoneGreenIcon
    }
}

struct EmailAddress: ContactMethod {
    let id: String
    let value: String
    let image: ImageResource

    init(id: String = UUID().uuidString, value: String) {
        self.id = id
        self.value = value
        self.image = .emailYellowIcon
    }
}

struct Facebook: ContactMethod {
    let id: String
    let value: String
    let image: ImageResource

    init(id: String = UUID().uuidString, value: String) {
        self.id = id
        self.value = value
        self.image = .facebookIcon
    }
}

struct Twitter: ContactMethod {
    let id: String
    let value: String
    let image: ImageResource

    init(id: String = UUID().uuidString, value: String) {
        self.id = id
        self.value = value
        self.image = .twitterIcon
    }
}

struct Blackbery: ContactMethod {
    let id: String
    let value: String
    let image: ImageResource

    init(id: String = UUID().uuidString, value: String) {
        self.id = id
        self.value = value
        self.image = .blackberryMessengerIcon
    }
}

struct Telegram: ContactMethod {
    let id: String
    let value: String
    let image: ImageResource

    init(id: String = UUID().uuidString, value: String) {
        self.id = id
        self.value = value
        self.image = .telegramIcon
    }
}

struct Instagram: ContactMethod {
    let id: String
    let value: String
    let image: ImageResource

    init(id: String = UUID().uuidString, value: String) {
        self.id = id
        self.value = value
        self.image = .instagramIcon
    }
}

struct Unimplemented: ContactMethod {
    var id: String
    var value: String
    var image: ImageResource

    internal init(id: String = "", value: String = "") {
        self.id = ""
        self.value = ""
        self.image = .avatar
    }
}
