import SwiftUI

enum HexagonType {
    case action
    case photo
    case contacts
    case various

    var color: Color {
        switch self {
        case .action:
            .appPurple
        case .photo:
            .appPurple
        case .contacts:
            .appGreen
        case .various:
            all.randomElement() ?? .appGray
        }
    }

    @ViewBuilder
    var icon: some View {
        switch self {
        case .action:
            EmptyView()
        case .photo:
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
        case .contacts:
            Image(.iconPhonebook)
                .resizable()
                .scaledToFit()
                .padding(.leading, -2)
        case .various:
            EmptyView()
        }
    }

    var randomColor: Color {
        all.randomElement() ?? .appGray
    }

    private var all: [Color] {
        [.appBlue, .appDarkBlue, .appGray, .appGreen, .appLightBlue, .appLightGreen, .appLightGreen, .appOrange, .appPink, .appPurple, .appGreen]
    }
}
