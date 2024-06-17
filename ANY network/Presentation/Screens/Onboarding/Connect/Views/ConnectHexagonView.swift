import SwiftUI

fileprivate
let connectArray: [ConnectItem] = [
    .init(color: Color.clear, opacity: 0, type: .various),
    .init(color: Color.clear, opacity: 0, type: .various),
    .init(color: Color.clear, opacity: 0, type: .various),
    .init(color: Color.clear, opacity: 0, type: .various),
    .init(color: Color.clear, opacity: 0, type: .various),
    .init(color: Color.appOrange, opacity: 0.12, type: .various),
    .init(color: Color.clear, opacity: 0, type: .various),
    .init(color: Color.clear, opacity: 0, type: .various),
    .init(color: Color.appPink, opacity: 0.12, type: .various),
    .init(color: Color.appBlue, opacity: 0.09, type: .various),
    .init(color: Color.appPink, opacity: 0.09, type: .various),
    .init(color: Color.appLightGreen, opacity: 0.09, type: .various),
    .init(color: Color.appLightBlue, opacity: 0.11, type: .various),
    .init(color: Color.appPurple, opacity: 0.36, type: .seedPhase),
    .init(color: Color.appOrange, opacity: 0.12, type: .various),
    .init(color: Color.clear, opacity: 0, type: .various),
    .init(color: Color.appLightGreen, opacity: 0.02, type: .various),
    .init(color: Color.appGreen, opacity: 0.15, type: .contacts),
    .init(color: Color.appYellow, opacity: 0.08, type: .various),
    .init(color: Color.appOrange, opacity: 0.1, type: .various),
    .init(color: Color.appYellow, opacity: 0.1, type: .various),
    .init(color: Color.appLightBlue, opacity: 0.1, type: .various),
    .init(color: Color.appGray, opacity: 0.1, type: .various),
    .init(color: Color.clear, opacity: 0.0, type: .various),
    .init(color: Color.clear, opacity: 0.0, type: .various),
    .init(color: Color.appPurple, opacity: 0.15, type: .various),
    .init(color: Color.appOrange, opacity: 0.15, type: .various),
]

struct ConnectHexagonView: View {
    private let action: () -> Void
    private let idx: Int
    private let count: Int
    private let item: ConnectItem
    private let enabled: Bool
    
    init(action: @escaping () -> Void, idx: Int, count: Int, typeEnabled: ConnectType? = nil) {
        self.action = action
        self.idx = idx
        self.count = count
        if idx < connectArray.count {
            self.item = connectArray[idx]
            self.enabled = self.item.type == typeEnabled
        } else {
            self.item = .init(color: Color.clear, opacity: 0, type: .various)
            self.enabled = false
        }
    }

    var opacity: CGFloat {
        let mid = CGFloat(count) / 2.0
        let opacity = (CGFloat(idx) < mid) ? CGFloat(idx) / CGFloat(mid) : 1 - CGFloat(idx) / CGFloat(count)
        return opacity
    }
    
    var body: some View {
        Button(action: action, label: {
            item.color
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                .clipShape(HexagonShape(cornerRadius: 8))
                .contentShape(HexagonShape(cornerRadius: 8))
                .clipped()
                .overlay(content: {
                    item.type.icon
                })
                .opacity(enabled ? 1.0 : item.opacity)
                .id(item.type)
        })
        .disabled(!enabled)
    }
}

#Preview {
    ConnectHexagonView(action: {}, idx: 0, count: 0)
}

struct ConnectItem {
    var color: Color
    var opacity: CGFloat
    var type: ConnectType
}

enum ConnectType {
    case seedPhase
    case contacts
    case various

    var color: Color {
        switch self {
        case .seedPhase:
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
        case .seedPhase:
            VStack(spacing: 0) {
                Text("12")
                    .font(.system(size: 45, weight: .bold))
                    .lineSpacing(0)
                Text("Words")
                    .font(.title3)
                    .lineSpacing(0)
            }
            .foregroundStyle(.white)
        case .contacts:
            Image(.iconPhonebook)
                .resizable()
                .frame(width: 55, height: 55)
                .padding(.top, 3)
        case .various:
            EmptyView()
        }
    }

    private var all: [Color] {
        [.appBlue, .appDarkBlue, .appGray, .appGreen, .appLightBlue, .appLightGreen, .appLightGreen, .appOrange, .appPink, .appPurple, .appGreen]
    }
}
