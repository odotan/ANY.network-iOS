import SwiftUI

extension View {
    @ViewBuilder
    func refreshable(isActive: Bool, action: @escaping () -> Void) -> some View {
        if isActive {
            self.refreshable { action() }
        } else {
            self
        }
    }
}
