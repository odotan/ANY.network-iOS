import SwiftUI
import Combine

struct ContactCell: View {
    private let contact: Contact
    @State private var selectedSwitcherItem: (any ContactMethod)?
    @StateObject private var swipeDetector = HorizontalSwipeDetector()

    private let onDragEvent = PassthroughSubject<DragGesture.Value, Never>()
    private let onDragEnd = PassthroughSubject<Void, Never>()
    
    private let methods: [any ContactMethod]

    init(contact: Contact) {
        self.contact = contact
        let methodCreator = ContactMethodCreator()

        self.methods = methodCreator.getFirstMethodForAllTypes(using: contact.allContactMethods)

        self._selectedSwitcherItem = State(initialValue: methods.first)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Group {
                if let data = contact.imageData {
                    AsyncImageWithCache(imageData: data, cacheKey: "\(data.hashValue)")
                } else {
                    Color.appRaisinBlack
                        .overlay {
                            Text(contact.abbreviation)
                                .font(Font.montserat(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                }
            }
            .frame(width: <->56.71, height: |64.19)
            .clipShape(HexagonShape(cornerRadius: 5))
            .onAppear { self.selectedSwitcherItem = methods.first }
            .zIndex(1)

            VStack(alignment: .leading, spacing: |2) {
                Text(contact.fullName)
                    .lineLimit(1)
                    .font(.montserat(size: |18, weight: .semibold))
                    .minimumScaleFactor(0.5)
                
                if let selectedSwitcherItem {
                    Text(selectedSwitcherItem.value)
                        .font(.montserat(size: |14))
                        .opacity(0.7)
                        .transition(.push(from: swipeDetector.swipeDirection.scrollFromEdge))
                        .id(UUID().uuidString)
                } else if let topNumber = contact.topNumber {
                    Text(topNumber)
                        .font(.montserat(size: |14))
                        .opacity(0.7)
                        .transition(.push(from: swipeDetector.swipeDirection.scrollFromEdge))
                        .id(topNumber)
                }
            }
            .padding(.horizontal, <->16)
            .foregroundColor(.white)
            .zIndex(0)

            Spacer()
            
            SwitcherView(
                contactMethods: methods,
                selectedItem: $selectedSwitcherItem,
                onContainingViewDragEvent: onDragEvent,
                onContainingViewDragEnd: onDragEnd
            )
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 25)
                .onChanged { value in
                    onDragEvent.send(value)
                    if methods.count > 1 {
                        withAnimation {
                            swipeDetector.swipe(value.translation.width)
                        }
                    }
                }
                .onEnded({ _ in
                    onDragEnd.send()
                    swipeDetector.release()
                })
        )
    }
}

private class HorizontalSwipeDetector: ObservableObject {
    @Published private(set) var swipeDirection: SwipeDirection = .left
    private var lastScrollValue: CGFloat = .zero
    private var cancellables = Set<AnyCancellable>()

    init() {
        $swipeDirection
            .removeDuplicates()
            .assign(to: &$swipeDirection)
    }

    public func swipe(_ value: Double) {
        if lastScrollValue > value && swipeDirection == .left {
            self.swipeDirection = .right
        } else if lastScrollValue < value && swipeDirection == .right {
            self.swipeDirection = .left
        }
        lastScrollValue = value
    }

    public func release() {
        self.lastScrollValue = .zero
    }

    fileprivate enum SwipeDirection {
        case left, right

        var scrollFromEdge: Edge {
            switch self {
            case .left:
                return .leading
            case .right:
                return .trailing
            }
        }
    }
}

#Preview {
    ContactCell(
        contact: Contact(
            id: "asd",
            givenName: "Te",
            middleName: "Lee",
            familyName: "Ard",
            phoneNumbers: [.init(
                id: "ASd",
                label: "phone",
                value: "02982367364"
            )],
            emailAddresses: [.init(id: "Email", label: "Email", value: "Email")],
            postalAddresses: [.init(id: "Post", label: "Post", value: "Post")],
            urlAddresses: [.init(id: "URL", label: "URL", value: "URL")],
            socialProfiles: [.init(id: "Instagram", label: "Instagram", value: "IG")],
            instantMessageAddresses: [.init(id: "Facebook", label: "Facebook", value: "FB")],
            imageData: nil,
            imageDataAvailable: false,
            isFavorite: false
        )
    )
        .background(.appBackground)
}
