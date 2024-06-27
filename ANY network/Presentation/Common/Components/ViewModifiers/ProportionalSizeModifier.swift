import SwiftUI

struct ProportionalSizeModifier: ViewModifier {
    var widthFactor: CGFloat
    var heightFactor: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width * widthFactor, height: geometry.size.height * heightFactor)
        }
    }
}

struct RelevantSizeModifier: ViewModifier {
    var designWidth: CGFloat = 375
    var designHeight: CGFloat = 812

    var width: CGFloat
    var height: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(
                width: width * (UIScreen.current?.bounds.size.width ?? 1) / designWidth,
                height: height * (UIScreen.current?.bounds.size.height ?? 1) / designHeight
            )
    }
}

struct RelevantPaddingModifier: ViewModifier {
    private let designWidth: CGFloat = 375

    var edges: Edge.Set
    var length: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(edges, length * (UIScreen.current?.bounds.size.width ?? 1) / designWidth)
    }
}

struct RelevantOffsetModifier: ViewModifier {
    private let designWidth: CGFloat = 375

    var x: CGFloat?
    var y: CGFloat?
    
    func body(content: Content) -> some View {
        if let x = x {
            if let y = y {
                content
                    .offset(x: x * (UIScreen.current?.bounds.size.width ?? 1) / designWidth)
                    .offset(y: y * (UIScreen.current?.bounds.size.width ?? 1) / designWidth)
            } else {
                content
                    .offset(x: x * (UIScreen.current?.bounds.size.width ?? 1) / designWidth)
            }
            
        } else if let y = y {
            content
                .offset(y: y * (UIScreen.current?.bounds.size.width ?? 1) / designWidth)
        }
    }
}

extension View {
    func frame(widthFactor: CGFloat, heightFactor: CGFloat) -> some View {
        self.modifier(ProportionalSizeModifier(widthFactor: widthFactor, heightFactor: heightFactor))
    }

    func frame(relevantWidth width: CGFloat, relevantHeight height: CGFloat) -> some View {
        self.modifier(RelevantSizeModifier(width: width, height: height))
    }
    
    func padding(_ edges: Edge.Set, relevantLength length: CGFloat) -> some View {
        self.modifier(RelevantPaddingModifier(edges: edges, length: length))
    }
    
    func offset(relevantX: CGFloat? = nil, relevantY: CGFloat? = nil) -> some View {
        self.modifier(RelevantOffsetModifier(x: relevantX, y: relevantY))
    }
}

