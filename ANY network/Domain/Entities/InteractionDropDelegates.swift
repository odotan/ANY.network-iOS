import SwiftUI

final class InteractionDropDelegate: DropDelegate {
    private let onDrop: (String) -> Void
    private let onTarget: (Bool) -> Void
    
    init(onDrop: @escaping (String) -> Void, onTarget: @escaping (Bool) -> Void = { _ in }) {
        self.onDrop = onDrop
        self.onTarget = onTarget
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [.text]) else {
            return false
        }
        
        let items = info.itemProviders(for: [.text])
        for item in items {
            _ = item.loadObject(ofClass: String.self) { id, _ in
                guard let id else { return }
                DispatchQueue.main.async { [weak self] in self?.onDrop(id) }
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        DispatchQueue.main.async { [weak self] in self?.onTarget(true) }
    }
    
    func dropExited(info: DropInfo) {
        DispatchQueue.main.async { [weak self] in self?.onTarget(false) }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
