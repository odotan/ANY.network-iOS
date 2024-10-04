import Foundation
import UIKit

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
}

struct ContactActionCreator {
    func createAction(for method: any ContactMethod) -> (any ContactAction)? {
        switch method.self {
        case is PhoneNumber:
            PhoneNumberAction(value: method.value)
        case is EmailAddress:
            EmailAction(value: method.value)
        default:
            nil
        }
    }
}
