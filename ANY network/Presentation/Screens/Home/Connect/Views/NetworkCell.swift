import SwiftUI

struct NetworkCell: View {
    let animationNamespace: Namespace.ID

    @Binding var zoomLevel: CGFloat
    let item: NetworkItem
    var wordsCount: Int?
    var size: CGSize
    var pressed: (() -> Void)

    var body: some View {
        Button(action: pressed) {
            item.backgroundColor
                .overlay {
                    VStack {
                        if item == .words {
                            VStack {
                                Text("\(wordsCount ?? 0)")
                                    .font(.montserat(size: 24, weight: .bold))
                                Text("Words")
                                    .font(.montserat(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                        } else {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .scaleEffect(1 / zoomLevel)
//                                .matchedGeometryEffect(id: "\(item.imageName)-logo", in: animationNamespace) // Unique per item
                        }
                    }
                }
        }
        .buttonStyle(.plain)
        .clipShape(HexagonShape(cornerRadius: 6))
    }
}

enum NetworkItem {
    case words
    case facebook
    case phone
    case email
    case contacts
    case messanger
    case instagram
    case telegram
    case etherium
    case bitcoin
    case url
    case skype
    case tiktok
    case linkedin
    case whatsapp

    var title: String {
        switch self {
        case .words:
            ""
        case .facebook:
            "Facebook"
        case .phone:
            "Phone"
        case .email:
            "Email"
        case .contacts:
            "Contacts"
        case .messanger:
            "Messanger"
        case .instagram:
            "Instagram"
        case .telegram:
            "Telegram"
        case .etherium:
            "Etherium"
        case .bitcoin:
            "Bitcoin"
        case .url:
            "URL"
        case .skype:
            "Skype"
        case .tiktok:
            "TikTok"
        case .linkedin:
            "Linkedin"
        case .whatsapp:
            "Whatsapp"
        }
    }

    var imageName: String {
        switch self {
        case .words:
            ""
        case .facebook:
            "facebook_icon"
        case .phone:
            "phone_icon"
        case .email:
            "email_icon"
        case .contacts:
            "contacts_icon"
        case .messanger:
            "messanger_icon"
        case .instagram:
            "instagram_icon"
        case .telegram:
            "telegram_icon"
        case .etherium:
            "etherium_icon"
        case .bitcoin:
            "btc_icon"
        case .url:
            "url_icon"
        case .skype:
            "skype_icon"
        case .tiktok:
            "tiktok_icon"
        case .linkedin:
            "linkedin_icon"
        case .whatsapp:
            "whatsapp_icon"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .words:
            .appPurple
        case .facebook:
            .appBlue
        case .phone:
            .appLightBlue
        case .email:
            .appYellow
        case .contacts:
            .appGreen
        case .messanger:
            .appPink
        case .instagram:
            .appOrange
        case .telegram:
            .appDarkBlue
        case .etherium:
            .appGray
        case .bitcoin:
            .appYellow
        case .url:
            .appPurple
        case .skype:
            .appBlue
        case .tiktok:
            .appPink
        case .linkedin:
            .appDarkBlue
        case .whatsapp:
                .appGreen
        }
    }
    
    static var connectOrder: [Int: NetworkItem] {
        [
            0: .words,
            2: .facebook,
            1: .phone,
            5: .email,
            6: .contacts,
            3: .messanger,
            4: .instagram,
            17: .telegram,
            16: .etherium,
            11: .bitcoin
        ]
    }

    static var requestOrder: [Int: NetworkItem] {
        [
            0: .url,
            2: .facebook,
            1: .phone,
            5: .email,
            6: .contacts,
            7: .skype,
            3: .messanger,
            4: .instagram,
            11: .bitcoin,
            18: .tiktok,
            16: .etherium,
            35: .telegram,
            17: .linkedin,
            34: .whatsapp
        ]
    }

}
