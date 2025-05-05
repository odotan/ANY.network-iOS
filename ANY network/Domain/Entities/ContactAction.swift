import Foundation
import UIKit

@MainActor
protocol ContactAction {
    associatedtype T
    var value: T { get }
    func performAction() throws
}

struct PhoneNumberAction: ContactAction {
    var value: String
    private let urlPrefix = "tel://"

    func performAction() throws {
        guard !value.isEmpty else { throw ContactActionError.noValue }
        guard value.isPhoneNumber else { throw ContactActionError.invalidValue }

        let urlString = urlPrefix + value
        guard let url = URL(string: urlString) else { throw ContactActionError.cantCreateURL }

        guard UIApplication.shared.canOpenURL(url) else { throw ContactActionError.cantOpenUrl }
        UIApplication.shared.open(url)
    }
}

struct EmailAction: ContactAction {
    var value: String
    private let urlPrefix = "mailto:"

    func performAction() throws {
        guard !value.isEmpty else { throw ContactActionError.noValue }
        guard value.isEmail else { throw ContactActionError.invalidValue }

        let urlString = urlPrefix + value
        guard let url = URL(string: urlString) else { throw ContactActionError.cantCreateURL }

        guard UIApplication.shared.canOpenURL(url) else { throw ContactActionError.cantOpenUrl }
        UIApplication.shared.open(url)
    }
}

struct ToggleFavouriteAction: ContactAction {
    var value: String
    var toggleFavoriteUseCase: ToggleFavoriteUseCase
    var onTaskComplete: (_ isFavourite: Bool) -> Void

    func performAction() throws {
        Task {
            let isFavourite = try await toggleFavoriteUseCase.execute(value)
            await MainActor.run {
                onTaskComplete(isFavourite)
            }
        }
    }
}

struct CheckIfFavouriteAction: ContactAction {
    var value: String
    var checkIfFavoriteUseCase: CheckIfFavoriteUseCase
    var onTaskComplete: (_ isFavourite: Bool) -> Void

    func performAction() throws {
        Task {
            let isFavourite = try await checkIfFavoriteUseCase.execute(value)
            await MainActor.run {
                onTaskComplete(isFavourite)
            }
        }
    }
}

enum ContactActionError: Error {
    case noValue, invalidValue, cantCreateURL, cantOpenUrl

    var description: String {
        switch self {
        case .noValue:
            "This method is missing a value."
        case .invalidValue:
            "The value for this method is not valid."
        case .cantCreateURL:
            "Can't create a link for this method."
        case .cantOpenUrl:
            "The device has no application that can execute this request."
        }
    }
}

struct ContactActionCreator {
    func createAction(for method: any ContactMethod) throws -> any ContactAction {
        switch method.self {
        case is PhoneNumber:
            PhoneNumberAction(value: method.value)
        case is EmailAddress:
            EmailAction(value: method.value)
        default:
            throw ContactActionCreationError.invalidActionType
        }
    }

    func createAction(for interaction: LabeledValue) throws -> any ContactAction {
        switch interaction.infoType {
        case is PhoneNumberType:
            PhoneNumberAction(value: interaction.value)
        case is EmailAddressType:
            EmailAction(value: interaction.value)
        default:
            throw ContactActionCreationError.invalidActionType
        }
    }
}

enum ContactActionCreationError: Error {
    case invalidActionType
}
