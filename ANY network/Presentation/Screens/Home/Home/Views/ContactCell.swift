import SwiftUI

struct ContactCell: View {
    private let contact: Contact
    
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
                            Image(.avatar)
                                .resizable()
                                .frame(width: <->26.37, height: |30.7)
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
            
            SwitcherView() 
        }
    }
}
