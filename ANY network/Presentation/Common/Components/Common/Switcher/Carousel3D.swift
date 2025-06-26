import SwiftUI
import CoreHaptics
import Combine

// MARK: Custom View
struct Carousel3D<Content: View, Items>: View where Items: RandomAccessCollection, Items.Indices.Element == Int, Items.Element == any ContactMethod {
    var cardSize: CGSize
    var numberOfItems: Int
    var items: Items
    var swipeValue: ((CGFloat) -> Void)
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
        swipeValue: @escaping ((CGFloat) -> Void),
        @ViewBuilder content: @escaping (Items.Element) -> Content
    ) {
        self.cardSize = cardSize
        self.numberOfItems = items.count
        self.items = items
        self._selectedItem = selectedItem
        self.onContainingViewDragEvent = onContainingViewDragEvent
        self.onContainingViewDragEnd = onContainingViewDragEnd
        self.content = content
        self.swipeValue = swipeValue
        
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
            .simultaneousGesture(
                DragGesture(minimumDistance: 25)
                    .onChanged { value in
                        onDrag(width: value.translation.width)
                        swipeValue(value.translation.width)
                    }
                    .onEnded({ _ in onDragEnd() })
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
                    try? HapticService.shared.perform()
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
            .onReceive(onContainingViewDragEvent, perform: {
                // ContactCell drag has a minimum value of 25, so there is a jump when dragging
                let originalWidth = $0.translation.width
                // Get the sign of the value and subtract or add 25
                let offsetToRemove = 25 * -$0.translation.width.signum()
                onDrag(width: originalWidth + offsetToRemove)
            })
            .onReceive(onContainingViewDragEnd, perform: { _ in onDragEnd() })
            .onAppear(perform: snapToPosition)
    }
    // MARK: - Converting SwiftUI View Into UIKit View
    func convertToUIView(item: Items.Element) -> UIHostingController<Content> {
        let hostingView = UIHostingController(rootView: content(item))
        hostingView.view.frame.origin = .init(x: cardSize.width / 2, y: cardSize.height / 2)
        hostingView.view.backgroundColor = .clear

        return hostingView
    }

    private func onDrag(width: CGFloat) {
        animationDuration = 0

        // MARK: Slowing Down
        let speed: CGFloat = speedSensitivity / CGFloat(items.count)
        let initial = width - lastReleasedWidth

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
                onDragEnd(width: width)
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

    func onDragEnd(width: CGFloat = .zero) {
        lastReleasedWidth = width
        snapToPosition()
    }
}

#Preview("Standard") {
    let methods: [any ContactMethod] = [
        Facebook(value: "@LeeAsd"),
        Blackbery(value: "@LeeAsdBla"),
        PhoneNumber(value: "01851923616"),
        Twitter(value: "@LeeAasdTwi"),
        Instagram(value: "@LeeAasdTwi"),
        EmailAddress(value: "email")
    ]

    SwitcherView(contactMethods: methods, selectedItem: .constant(methods.first), swipeValue: { _ in })
        .background(.appBackground)
}

#Preview("Less than 6 items") {
    let methods: [any ContactMethod] = [
        Facebook(value: "@LeeAsd"),
        Blackbery(value: "@LeeAsdBla"),
        PhoneNumber(value: "01851923616"),
        Twitter(value: "@LeeAasdTwi"),
        Instagram(value: "@LeeAasdTwi")
    ]

    SwitcherView(contactMethods: methods, selectedItem: .constant(methods.first), swipeValue: { _ in })
        .background(.appBackground)
}

#Preview("1 item") {
    let methods: [any ContactMethod] = [
        Facebook(value: "@LeeAsd")
    ]

    SwitcherView(contactMethods: methods, selectedItem: .constant(methods.first), swipeValue: { _ in })
        .background(.appBackground)
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

extension FloatingPoint {
  @inlinable
  func signum() -> Self {
    if self < 0 { return -1 }
    if self > 0 { return 1 }
    return 0
  }
}
