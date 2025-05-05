import Foundation
import SwiftUI

extension ConnectNetworkSignUpViewModel {
    struct State: Equatable {
        let networkItem: NetworkItem
        let contact: Contact
        var showCodeField: Bool = false
        var code: String = ""
        var showInputField: Bool = false
        var inputValue: String = ""
        var inputValueKeyboardType: UIKeyboardType = .default
        var error: EquatableError?
        var continueButtonIsVisible: Bool = true
    }
    
    enum Event {
        case showConfirmation
        case goBack
        case sendRequest
        case updateCode(String)
        case updateInputField(String)
        case hideError
    }
}

struct EquatableError: LocalizedError, Equatable {
    let error: Error
    
    var errorDescription: String? {
        (error as? LocalizedError)?.errorDescription ?? (error as NSError).localizedDescription
    }

    static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        lhs.error.localizedDescription == rhs.error.localizedDescription
    }
}

extension NSError: LocalizedError {
    public var errorDescription: String? {
        return localizedDescription
    }
}
