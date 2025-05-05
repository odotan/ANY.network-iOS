import SwiftUI

struct PillToolbarView: View {
    let items: [PillToolbarItem]

    private var leadingItems: [PillToolbarItem]? {
        items.filter { $0.position == .leading }
    }
    
    private var trailingItems: [PillToolbarItem]? {
        items.filter { $0.position == .trailing }
    }
    
    private var middleItems: [PillToolbarItem]? {
        items.filter { $0.position == .middle }
    }
    
    @ViewBuilder
    private var backgroundVE: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            .overlay{ Color.appBackground.opacity(0.4) }
    }

    var body: some View {
        ZStack {
            leading
            
            middle
            
            traling
        }
        .frame(height: |48)
    }
    
    @ViewBuilder
    var leading: some View {
        if let safeLeadingItems = leadingItems, !safeLeadingItems.isEmpty {
            HStack {
                HStack(spacing: 15) {
                    ForEach(0..<safeLeadingItems.count, id: \.self) { index in
                        let item = safeLeadingItems[index]
                        
                        PillToolbarItemView(icon: item.icon, action: item.action)
                        
                        if index < safeLeadingItems.count - 1 {
                            Color.white.opacity(0.15)
                                .frame(width: 0.5, height: |22)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.leading, 9)
                .padding(.trailing, 13)
                .background(backgroundVE)
                .cornerRadiusWithBorder(
                    cornerRadii: .init(bottomTrailing: 24, topTrailing: 24),
                    borderLineWidth: 0,
                    borderColor: .clear
                )
                
                Spacer()
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var middle: some View {
        if let safeMiddleItems = middleItems, !safeMiddleItems.isEmpty {
            HStack(spacing: 15) {
                ForEach(0..<safeMiddleItems.count, id: \.self) { index in
                    let item = safeMiddleItems[index]
                    
                    PillToolbarItemView(icon: item.icon, action: item.action)
                    
                    if index < safeMiddleItems.count - 1 {
                        Color.white.opacity(0.15)
                            .frame(width: 0.5, height: |22)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(backgroundVE)
            .cornerRadius(24)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var traling: some View {
        if let safeTrailingItems = trailingItems, !safeTrailingItems.isEmpty {
            HStack {
                Spacer()
                
                HStack(spacing: 15) {
                    ForEach(0..<safeTrailingItems.count, id: \.self) { index in
                        let item = safeTrailingItems[index]
                        
                        PillToolbarItemView(icon: item.icon, action: item.action)
                        
                        if index < safeTrailingItems.count - 1 {
                            Color.white.opacity(0.15)
                                .frame(width: 0.5, height: |22)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.leading, 9)
                .padding(.trailing, 13)
                .background(backgroundVE)
                .cornerRadiusWithBorder(
                    cornerRadii: .init(topLeading: 24, bottomLeading: 24),
                    borderLineWidth: 0,
                    borderColor: .clear
                )
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    Color.appBackground
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .pillToolbar(items: [
            .init(icon: .back, position: .leading, action: {}),
            .init(icon: .add, position: .trailing, action: {}),
            .init(icon: .add, position: .middle, action: {}),
            .init(icon: .message, position: .middle, action: {}),
            .init(icon: .favorite, position: .middle, action: {}),
            .init(icon: .search, position: .middle, action: {})
        ])
}

struct PillToolbarViewModifier: ViewModifier {
    let items: [PillToolbarItem]
    let visible: Bool

    func body(content: Content) -> some View {
        if visible {
            content
                .edgesIgnoringSafeArea(.bottom)
                .overlay(alignment: .bottom) {
                    PillToolbarView(items: items)
                        .padding(.bottom, 31)
                }
        } else {
            content
        }
    }
}

extension View {
    func pillToolbar(items: [PillToolbarItem], visible: Bool = true) -> some View {
        modifier(PillToolbarViewModifier(items: items, visible: visible))
    }
}
