import SwiftUI
import Combine

struct ContactCell: View {
    private let contact: Contact

    private let onDragEvent = PassthroughSubject<DragGesture.Value, Never>()
    private let onDragEnd = PassthroughSubject<Void, Never>()

    init(contact: Contact) {
        self.contact = contact
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
            
            VStack(alignment: .leading, spacing: |2) {
                Text(contact.fullName)
                    .lineLimit(1)
                    .font(.montserat(size: |18, weight: .semibold))
                    .minimumScaleFactor(0.5)
                
                if let topNumber = contact.topNumber {
                    Text(topNumber)
                        .font(.montserat(size: |14))
                        .opacity(0.7)
                }
            }
            .padding(.horizontal, <->16)
            .foregroundColor(.white)
            
            Spacer()
            
            SwitcherView(onContainingViewDragEvent: onDragEvent, onContainingViewDragEnd: onDragEnd)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onChanged(onDragEvent.send)
                .onEnded({ _ in onDragEnd.send() })
        )
    }
}

#Preview {
    ContactCell(contact: Contact(id: "asd", givenName: "Te", middleName: "Lee", familyName: "Ard", phoneNumbers: [], emailAddresses: [], postalAddresses: [], urlAddresses: [], socialProfiles: [], instantMessageAddresses: [], imageData: nil, imageDataAvailable: false, isFavorite: false))
}
