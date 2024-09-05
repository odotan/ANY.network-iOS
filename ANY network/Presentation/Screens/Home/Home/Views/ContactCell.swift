import SwiftUI
import Combine

struct ContactCell: View {
    private let contact: Contact
    @State private var selectedSwitcherItem: (any ContactMethod)?

    private let onDragEvent = PassthroughSubject<DragGesture.Value, Never>()
    private let onDragEnd = PassthroughSubject<Void, Never>()
    
    private let methodos: [any ContactMethod]

    init(contact: Contact) {
        self.contact = contact
        #warning("Hardcoded values for testing, remove later")
        self.methodos = [
            Facebook(id: "facebook", value: "Tes Ting"),
            Blackbery(id: "blackbery", value: "_TesTingBlackbery"),
            PhoneNumber(id: "phone", value: "01851923616"),
            Twitter(id: "twitter", value: "...TesTingTwitter"),
            Instagram(id: "instagram", value: "@TesTingInsta"),
        ]
        self._selectedSwitcherItem = State(initialValue: methodos.first)
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
            .onAppear { self.selectedSwitcherItem = methodos.first }

            VStack(alignment: .leading, spacing: |2) {
                Text(contact.fullName)
                    .lineLimit(1)
                    .font(.montserat(size: |18, weight: .semibold))
                    .minimumScaleFactor(0.5)
                
                if let selectedSwitcherItem {
                    Text(selectedSwitcherItem.value)
                        .font(.montserat(size: |14))
                        .opacity(0.7)
                } else if let topNumber = contact.topNumber {
                    Text(topNumber)
                        .font(.montserat(size: |14))
                        .opacity(0.7)
                }
            }
            .padding(.horizontal, <->16)
            .foregroundColor(.white)
            
            Spacer()

            SwitcherView(
                contactMethods: methodos,
                selectedItem: $selectedSwitcherItem,
                onContainingViewDragEvent: onDragEvent,
                onContainingViewDragEnd: onDragEnd
            )
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged(onDragEvent.send)
                .onEnded({ _ in onDragEnd.send() })
        )
    }
}

#Preview {
    ContactCell(contact: Contact(id: "asd", givenName: "Te", middleName: "Lee", familyName: "Ard", phoneNumbers: [.init(id: "ASd", label: "phone", value: "02982367364")], emailAddresses: [], postalAddresses: [], urlAddresses: [], socialProfiles: [], instantMessageAddresses: [], imageData: nil, imageDataAvailable: false, isFavorite: false))
        .background(.appBackground)
}
