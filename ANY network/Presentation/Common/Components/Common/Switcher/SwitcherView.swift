import SwiftUI
import Combine

struct SwitcherView: View {
    let numberOfCells = 6

    @State private var cards: [SwitcherItem]
    @Binding private var selectedItem: (any ContactMethod)?
    private var contactMethods: [any ContactMethod]

    private let onContainingViewDragEvent: PassthroughSubject<DragGesture.Value, Never>
    private let onContainingViewDragEnd: PassthroughSubject<Void, Never>

    init(
        contactMethods: [any ContactMethod],
        selectedItem: Binding<(any ContactMethod)?>,
        onContainingViewDragEvent: PassthroughSubject<DragGesture.Value, Never> = .init(),
        onContainingViewDragEnd: PassthroughSubject<Void, Never> = .init()
    ) {
        self.contactMethods = contactMethods
        self._selectedItem = selectedItem
        self._cards = State(initialValue: contactMethods.map({ .init(id: $0.id, imageName: $0.image) }))
        self.onContainingViewDragEvent = onContainingViewDragEvent
        self.onContainingViewDragEnd = onContainingViewDragEnd
    }

    var body: some View {
        VStack {
            Carousel3D(
                cardSize: CGSize(width: <->28, height: |27.16),
                numberForItems: numberIfItemsExacludingEmpty,
                items: cards, 
                selectedItem: selectedItemBinding,
                onContainingViewDragEvent: onContainingViewDragEvent,
                onContainingViewDragEnd: onContainingViewDragEnd,
                content: { card in
                    SwitcherItemView(item: card)
                }
            )
        }
        .frame(width: <->64.49, height: |28.23)
        .mask(overlay)
        .clipShape(Rectangle())
    }
    
    var numberIfItemsExacludingEmpty: Int {
        cards.filter { $0.imageName != nil }.count
    }
    
    @ViewBuilder
    var overlay: some View {
        HStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appBackground.opacity(0.7),
                    Color.clear
                ],
                startPoint: .trailing,
                endPoint: .leading
            ).frame(width: 22)
            
            Color.white
            
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.appBackground.opacity(0.7),
                    Color.appBackground
                ],
                startPoint: .trailing,
                endPoint: .leading
            ).frame(width: 22)
        }
    }

    var selectedItemBinding: Binding<SwitcherItem?> {
        let itemId = self.selectedItem?.id ?? self.contactMethods.first?.id
        return Binding(
            get: { SwitcherItem(id: itemId ?? "", imageName: self.selectedItem?.image) },
            set: { newItem in
                self.selectedItem = contactMethods.first(where: { $0.id == newItem?.id })
            }
        )
    }
}

#Preview {
    @State var methods: [any ContactMethod] = [
        Facebook(value: "@LeeAsd"),
        Blackbery(value: "@LeeAsdBla"),
        PhoneNumber(value: "01851923616"),
        Twitter(value: "@LeeAasdTwi")
    ]

    @State var selected: (any ContactMethod)?

    return VStack(alignment: .leading) {
        SwitcherView(contactMethods: methods, selectedItem: $selected)
            .background(.appBackground)
            .onAppear { selected = methods.first }
    }
//    .background(Color.appBackground)
}
