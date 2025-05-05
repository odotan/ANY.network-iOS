import SwiftUI

private struct DropDestinationWithPosition<T: Transferable>: ViewModifier {
    @State private var targetPosition: CGPoint?
    private let priorityOfThisHex: Int?
    private let targetedHex: Int?
    private let type: T.Type
    private let onDrop: ([T], CGPoint) -> Bool
    private let onTarget: (Bool, CGPoint?) -> Void
    
    init(
        priorityOfThisHex: Int?,
        targetedHex: Int?,
        type: T.Type,
        onDrop: @escaping ([T], CGPoint) -> Bool,
        onTarget: @escaping (Bool, CGPoint?) -> Void
    ) {
        self.targetedHex = targetedHex
        self.priorityOfThisHex = priorityOfThisHex
        self.type = type
        self.onDrop = onDrop
        self.onTarget = onTarget
    }
    
    func body(content: Content) -> some View {
        if let targetedHex, let priorityOfThisHex, targetedHex == priorityOfThisHex {
            GeometryReader { reader in
                content
                    .dropDestination(for: type) { items, dropPosition in
                        self.targetPosition = nil
                        return onDrop(items, dropPosition)
                    } isTargeted: { bool in
                        self.targetPosition = reader.frame(in: .global).centerPoint
                        onTarget(bool, targetPosition)
                    }
            }
        } else {
            content
                .dropDestination(for: type, action: onDrop, isTargeted: { onTarget($0, nil) })
        }
    }
}

extension View {
    func dropDestinationWithTargetPosition<T: Transferable>(
        priorityOfThisHex: Int?,
        targetedHex: Int?,
        type: T.Type,
        onDrop: @escaping ([T], CGPoint) -> Bool,
        onTarget: @escaping (Bool, CGPoint?) -> Void
    ) -> some View {
        self.modifier(
            DropDestinationWithPosition(
                priorityOfThisHex: priorityOfThisHex,
                targetedHex: targetedHex,
                type: type,
                onDrop: onDrop,
                onTarget: onTarget
            )
        )
    }
}
