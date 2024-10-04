import SwiftUI
import CoreHaptics
import Combine

// MARK: Custom View
struct Carousel3D<Content: View, Items>: View where Items: RandomAccessCollection, Items.Indices.Element == Int, Items.Element: Identifiable, Items.Element: Equatable {
    var cardSize: CGSize
    var numberOfItems: Int
    var items: Items
    var content: (Items.Element) -> Content

    var hostingViews: [UIView] = []

    let speedSensitivity: CGFloat = 25

    // MARK: Gesture Properties
    @State var offset: CGFloat = 0
    @State var offsetDelta: CGFloat = 0
    @State var lastReleasedWidth: CGFloat = .zero
    @State var lastStoredOffset: CGFloat = 0
    @State var animationDuration: CGFloat = 0
    @State var engine: CHHapticEngine?

    // MARK: Item Selection
    @StateObject private var indexObserver = IndexChangeObserver()
    @Binding private var selectedItem: Items.Element?

    private let onContainingViewDragEvent: PassthroughSubject<DragGesture.Value, Never>
    private let onContainingViewDragEnd: PassthroughSubject<Void, Never>

    init(
        cardSize: CGSize,
        items: Items,
        selectedItem: Binding<Items.Element?>,
        onContainingViewDragEvent: PassthroughSubject<DragGesture.Value, Never> = .init(),
        onContainingViewDragEnd: PassthroughSubject<Void, Never> = .init(),
        @ViewBuilder content: @escaping (Items.Element) -> Content
    ) {
        self.cardSize = cardSize
        self.numberOfItems = items.count
        self.items = items
        self._selectedItem = selectedItem
        self.onContainingViewDragEvent = onContainingViewDragEvent
        self.onContainingViewDragEnd = onContainingViewDragEnd
        self.content = content

        for item in items {
            let hostingView = convertToUIView(item: item).view!
            hostingViews.append(hostingView)
        }
    }

    var body: some View {
        CarouselHelper(views: hostingViews, cardSize: cardSize, offset: offset, animationDuration: animationDuration)
            .frame(width: cardSize.width, height: cardSize.height)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged(onDrag)
                    .onEnded({ value in
                        lastReleasedWidth = .zero
                        snapToPosition()
                    })
            )
            .onChange(of: items.count) { _, newValue in
                guard newValue > 0 else { return }

                // MARK: Animating When Item is Removed or Inserted
                animationDuration = 0.2

                // start from the middle if only 3 items are provided
                offset = numberOfItems == 3 ? -90 : 0//CGFloat(Int((offset / anglePerCard).rounded())) * anglePerCard
                lastStoredOffset = offset
            }
            .onChange(of: offset, { oldValue, newValue in
                let circleAngle: CGFloat = 360.0 / CGFloat(hostingViews.count)
                let angle: CGFloat = offset
                offsetDelta = angle.truncatingRemainder(dividingBy: circleAngle)
            })
            .onChange(of: offsetDelta, { oldValue, newValue in
                let circleAngle: CGFloat = 360.0 / CGFloat(hostingViews.count)

                let delta = abs(oldValue - newValue)
                //                print(delta, oldValue, newValue)
                if delta > circleAngle / 2 {
                    try? HepticService.shared.perform()
                }

                let draggingItemOffset = (-Int(offset / circleAngle) % hostingViews.count)

                indexObserver.changingIndex = draggingItemOffset < 0 ? numberOfItems + draggingItemOffset : draggingItemOffset % numberOfItems

                //                print("DeltaOffset:", Int(offset / circleAngle), "MoveBy:", (Int(offset / circleAngle) % hostingViews.count), "withCurrent:", indexObserver.currentIndex.description, "To new index:", draggingItemOffset < 0 ? numberOfItems + draggingItemOffset : draggingItemOffset % numberOfItems)
            })
            .onReceive(indexObserver.$currentIndex) { index in
                withAnimation {
                    if items.count > index {
                        self.selectedItem = items[index]
                    }
                }
            }
            .onReceive(onContainingViewDragEvent, perform: { onDrag(value: $0) })
            .onReceive(onContainingViewDragEnd, perform: {
                lastReleasedWidth = .zero
                snapToPosition()
            })
            .onAppear(perform: snapToPosition)
    }
    // MARK: - Converting SwiftUI View Into UIKit View
    func convertToUIView(item: Items.Element) -> UIHostingController<Content> {
        let hostingView = UIHostingController(rootView: content(item))
        hostingView.view.frame.origin = .init(x: cardSize.width / 2, y: cardSize.height / 2)
        hostingView.view.backgroundColor = .clear

        return hostingView
    }

    private func onDrag(value: DragGesture.Value) {
        animationDuration = 0

        // MARK: Slowing Down
        let speed: CGFloat = speedSensitivity / CGFloat(items.count)
        let initial = value.translation.width - lastReleasedWidth

        let temp = (initial * speed) + lastStoredOffset

        let circleAngle = 360.0 / CGFloat(items.count)
        let truncating = abs(temp.truncatingRemainder(dividingBy: circleAngle))
        //        print(abs(truncating), temp)
        //        print(truncating)

        switch items.count {
        case 1:
            break
//        case 2...5:
//            if temp > -(CGFloat(activeItemCount - 1) * circleAngle + 20) && temp < 20 {
//                offset = temp
//            }
        default:
            if truncating > 5 && truncating < circleAngle - 5 {
                offset = temp
            } else {
                lastReleasedWidth = value.translation.width
                snapToPosition()
            }
        }
    }

    private func snapToPosition() {
        guard hostingViews.count > 0 else {
            lastStoredOffset = offset
            return
        }

        // MARK: Adding Animation
        animationDuration = 0.2
        let anglePerCard = 360.0 / CGFloat(hostingViews.count)
        offset = CGFloat(Int((offset / anglePerCard).rounded())) * anglePerCard

        lastStoredOffset = offset
    }
}

#Preview("Standard") {
    @State var methods: [any ContactMethod] = [
        Facebook(value: "@LeeAsd"),
        Blackbery(value: "@LeeAsdBla"),
        PhoneNumber(value: "01851923616"),
        Twitter(value: "@LeeAasdTwi"),
        Instagram(value: "@LeeAasdTwi"),
        EmailAddress(value: "email")
    ]

    @State var selected: (any ContactMethod)?

    return SwitcherView(contactMethods: methods, selectedItem: $selected)
        .background(.appBackground)
        .onAppear { selected = methods.first }
}

#Preview("Less than 6 items") {
    @State var methods: [any ContactMethod] = [
        Facebook(value: "@LeeAsd"),
        Blackbery(value: "@LeeAsdBla"),
        PhoneNumber(value: "01851923616"),
        Twitter(value: "@LeeAasdTwi"),
        Instagram(value: "@LeeAasdTwi")
    ]

    @State var selected: (any ContactMethod)?

    return SwitcherView(contactMethods: methods, selectedItem: $selected)
        .background(.appBackground)
        .onAppear { selected = methods.first }
}

#Preview("1 item") {
    @State var methods: [any ContactMethod] = [
        Facebook(value: "@LeeAsd")
    ]

    @State var selected: (any ContactMethod)?

    return SwitcherView(contactMethods: methods, selectedItem: $selected)
        .background(.appBackground)
        .onAppear { selected = methods.first }
}

// MARK: UIKit UnWrapper
fileprivate
struct CarouselHelper: UIViewRepresentable {
    var views: [UIView]
    var cardSize: CGSize
    var offset: CGFloat
    var animationDuration: CGFloat

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // MARK: Adding Views as SubViews
        // Only Adding Single Time
        // Since We Need Cards to Form a Circle Shape
        let circleAngle = 360.0 / CGFloat(views.count)
        var angle: CGFloat = offset

        if uiView.subviews.count > views.count {
            // MARK: Remove Last Sub View
            uiView.subviews[uiView.subviews.count - 1].removeFromSuperview()
        }

        for (view, index) in zip(views, views.indices) {
            if uiView.subviews.indices.contains(index) {
                // ALREADY ADDED
                // SINCE IT"S ALREADY ADDED SO DO THE MODIFICATIONS HERE
                apply3DTransform(view: uiView.subviews[index], angle: angle)

                // MARK: We Need Disable All Other Card Rather Than Our Center To Enable Proper Button/Taps
                // Because It Can Increase 360 For Each Complete Turn
                // Reducing Complet Turns
                let completeRotation = CGFloat(Int(angle / 360)) * 360.0
                if (angle - completeRotation) == 0 {
                    uiView.subviews[index].isUserInteractionEnabled = true
                } else {
                    uiView.subviews[index].isUserInteractionEnabled = false
                }

                let delta = abs(angle - completeRotation)
                if delta > circleAngle * 1.3 && delta < 360 - circleAngle * 1.3 {
                    uiView.subviews[index].alpha = 0
                } else {
                    uiView.subviews[index].alpha = 1
                }

                angle += circleAngle
            } else {
                // ADD FOR THE FIRST TIME
                let hostView = view
                hostView.frame = .init(origin: .zero, size: cardSize)

                uiView.addSubview(hostView)

                apply3DTransform(view: uiView.subviews[index], angle: angle)
                angle += circleAngle
            }
        }
    }

    func apply3DTransform(view: UIView, angle: CGFloat) {
        // MARK: Adding 3D Transform
        var transform3D = CATransform3DIdentity
        transform3D.m34 = -1.0/500.0

        let completeRotation = CGFloat(Int(angle / 360)) * 360.0
        let delta = abs(angle - completeRotation)
        var scale = (0.5 + abs(delta - 180) / 360)
        scale = scale * 2 - 1

        //        print(delta, scale)

        // MARK: Transform Uses Radians
        let radius = Double(cardSize.width) * Double(views.count) / Double(2) / Double.pi
        transform3D = CATransform3DTranslate(transform3D, 0, 0, -radius)
        transform3D = CATransform3DRotate(transform3D, degToRad(deg: angle), 0, 1, 0)
        transform3D = CATransform3DTranslate(transform3D, 0, 0, radius)
        transform3D = CATransform3DScale(transform3D, scale, scale, 1)

        UIView.animate(withDuration: animationDuration) {
            view.transform3D = transform3D
        }
    }
}

func degToRad(deg: CGFloat) -> CGFloat {
    return (deg * .pi) / 180
}

fileprivate class IndexChangeObserver: ObservableObject {
    @Published var changingIndex: Int = 0
    @Published var currentIndex: Int = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        $changingIndex
            .removeDuplicates()
            .assign(to: &$currentIndex)
    }
}
