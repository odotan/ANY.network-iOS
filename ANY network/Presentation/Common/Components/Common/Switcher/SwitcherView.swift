import SwiftUI
import Combine

struct SwitcherView: View {
    let numberOfCells = 6

    @State var cards: [SwitcherItem] = []
    let icons: [ImageResource] = [.phoneIcon, .emailYellowIcon, .phoneGreenIcon, .facebookIcon, .blackberryMessengerIcon, .blackberryMessengerIcon]

    private let onContainingViewDragEvent: PassthroughSubject<DragGesture.Value, Never>
    private let onContainingViewDragEnd: PassthroughSubject<Void, Never>

    init(cards: [SwitcherItem] = [], onContainingViewDragEvent: PassthroughSubject<DragGesture.Value, Never> = .init(), onContainingViewDragEnd: PassthroughSubject<Void, Never> = .init()) {
        self.cards = [
            .init(imageName: .phoneIcon),
            .init(imageName: .emailYellowIcon),
            .init(imageName: .phoneGreenIcon),
            .init(imageName: .facebookIcon),
            .init(imageName: .blackberryMessengerIcon),
            .init(imageName: .phoneGreenIcon)
        ] // cards 
        self.onContainingViewDragEvent = onContainingViewDragEvent
        self.onContainingViewDragEnd = onContainingViewDragEnd
    }

    var body: some View {
        VStack {
            Carousel3D(
                cardSize: CGSize(width: <->28, height: |27.16),
                numberForItems: numberIfItemsExacludingEmpty,
                items: cards,
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
}

#Preview {
    VStack(alignment: .leading) {
        HStack {
            SwitcherView()
            Spacer()
        }
        Spacer()
    }
//    .background(Color.appBackground)
}
