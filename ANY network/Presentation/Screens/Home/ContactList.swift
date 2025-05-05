import SwiftUI

struct ContactList: View, Equatable {
    private let listToDisplay: [Contact]
    private let isRefreshActive: Bool
    private let onRowTapped: (Contact, CGPoint) -> Void
    private let onInteraction: (ContactInteraction) -> Void
    private let onRefresh: () -> Void
    
    init(
        listToDisplay: [Contact],
        isRefreshActive: Bool,
        onRowTapped: @escaping (Contact, CGPoint) -> Void,
        onInteraction: @escaping (ContactInteraction) -> Void,
        onRefresh: @escaping () -> Void
    ) {
        self.listToDisplay = listToDisplay
        self.isRefreshActive = isRefreshActive
        self.onRowTapped = onRowTapped
        self.onInteraction = onInteraction
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        List(listToDisplay) { contact in
            GeometryReader { geometry in
                Button {
                    let globalTapLocation = CGPoint(
                        x: geometry.frame(in: .global).midX,
                        y: geometry.frame(in: .global).minY
                    )
                    
                    onRowTapped(contact, globalTapLocation)
                } label: {
                    ContactCell(contact: contact, onInteraction: onInteraction)
                        .id(contact.id)
                        .layoutPriority(10)
                }
            }
            .frame(height: |64.19)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .padding(.bottom, contact.id == listToDisplay.last?.id ? 60 : nil)
        }
        .animation(nil, value: UUID())
        .refreshable(isActive: isRefreshActive, action: onRefresh)
        .listRowSpacing(-10)
        .listStyle(.plain)
    }
    
    static func == (lhs: ContactList, rhs: ContactList) -> Bool {
        lhs.listToDisplay == rhs.listToDisplay
    }
}
