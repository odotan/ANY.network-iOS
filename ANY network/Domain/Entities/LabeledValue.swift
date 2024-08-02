import Foundation

struct LabeledValue: Identifiable, Hashable, Equatable {
    let id: String
    let label: String
    let value: String
}
