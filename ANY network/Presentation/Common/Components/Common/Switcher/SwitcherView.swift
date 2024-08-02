import SwiftUI

struct SwitcherView: View {
    let numberOfCells = 6

    @State var cards: [SwitcherItem] = []
    let icons: [ImageResource] = [.phoneIcon, .emailYellowIcon, .phoneGreenIcon, .facebookIcon, .blackberryMessengerIcon, .blackberryMessengerIcon]

    var body: some View {
        VStack {
            Carousel3D(
                cardSize: CGSize(width: <->28, height: |27.16),
                numberForItems: numberIfItemsExacludingEmpty,
                items: cards,
                content: { card in
                    SwitcherItemView(item: card)
                }
            )
        }
        .frame(width: <->64.49, height: |28.23)
        .background(Color.appBackground)
        .overlay(overlay)
        .clipShape(Rectangle())
        .onAppear {
            for _ in 0..<numberOfCells {
                cards.append(.init(imageName: icons.randomElement()))
            }
//            cards.append(.init())
        }
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
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 0)
            ).frame(width: 22)
            
            Spacer()
            
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.appBackground.opacity(0.7),
                    Color.appBackground
                ],
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 0)
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
