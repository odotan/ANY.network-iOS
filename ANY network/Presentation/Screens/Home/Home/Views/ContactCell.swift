import SwiftUI

struct ContactCell: View {
    private let contact: Contact
    
    init(contact: Contact) {
        self.contact = contact
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Group {
                if let data = contact.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.appPurple
                        .overlay {
                            Text(String(contact.givenName.first!) + String(contact.familyName.first!))
                                .foregroundColor(.white)
                                .font(Font.custom(Font.montseratSemiBold, size: |22))

                        }
                }
            }
            .frame(width: <->56.71, height: |64.19)
            .clipShape(HexagonShape(cornerRadius: 5))
            
            VStack(alignment: .leading, spacing: |2) {
                Text(contact.givenName + " " + contact.familyName)
                    .lineLimit(1)
                    .font(Font.custom(Font.montseratSemiBold, size: |18))
                    .minimumScaleFactor(0.5)
                
                Text("+558 5225 22544")
                    .font(.custom(Font.montseratRegular, size: |14))
                    .opacity(0.7)
            }
            .padding(.horizontal, <->16)
            .foregroundColor(.white)
            
            Spacer()
        }
    }
}

#Preview {
    ContactCell(contact: Contact(id: "1", givenName: "Danail", familyName: "Vrachev", imageData: nil, imageDataAvailable: false))
        .background(.appBackground)
}
