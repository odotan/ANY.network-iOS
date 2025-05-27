import SwiftUI

struct Flower: View {
    var animationDone: (() -> Void)
    @State private var showImages = Array(repeating: false, count: 6)
    
    private let borderImages: [ImageResource] = [.flowerBorder0, .flowerBorder1, .flowerBorder2, .flowerBorder3, .flowerBorder4, .flowerBorder5]
    private let flowerImages: [ImageResource] = [.flowerCenter0, .flowerCenter1, .flowerCenter2, .flowerCenter3, .flowerCenter4, .flowerCenter5, .flowerCenter6]
    
    private let delay: CGFloat = 1/6
    private let animationDuration: CGFloat = 1/3

    var body: some View {
        ZStack {
            border
            flower
        }
        .onAppear {
            print("Flower: View appeared, starting animation sequence")
            for i in 0..<6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i + 1) * Double(delay)) {
                    print("Flower: Showing image \(i)")
                    showImages[i] = true
                }
            }
        }
        .onChange(of: showImages[5]) { _, newValue in
            if newValue {
                print("Flower: Last image appeared, completing animation")
                // Last animation appeared, delay by animationDuration to match end of animation
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    print("Flower: Calling animation completion callback")
                    self.animationDone()
                }
            }
        }
    }
    
    var flower: some View {
        ZStack {
            Image(flowerImages[0])
                .resizable()
                .scaledToFit()
            
            ForEach(0..<6, id: \.self) { index in
                Image(flowerImages[index + 1])
                    .resizable()
                    .scaledToFit()
                    .opacity(showImages[index] ? 1 : 0)
                    .animation(.easeIn(duration: animationDuration), value: showImages[index])
            }
        }
    }
    
    var border: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Image(borderImages[index])
                    .resizable()
                    .scaledToFit()
                    .opacity(showImages[index] ? 1 : 0)
                    .animation(.easeIn(duration: animationDuration), value: showImages[index])
            }
        }
        .scaleEffect(1.05)
    }
}
