//
//  DynamicIslandView.swift
//  ANY network
//
//  Created by Danail Vrachev on 30.07.25.
//

import SwiftUI

struct DynamicIslandView: View {
    @State private var safeAreaInsets: EdgeInsets = .init()
    
    var body: some View {
        GeometryReader { geometry in
            let hasDynamicIsland = safeAreaInsets.top > 47 // Dynamic Island devices have top safe area > 47
            let dynamicIslandHeight: CGFloat = hasDynamicIsland ? 37 : 0 // Approximate Dynamic Island height
            let extensionHeight: CGFloat = dynamicIslandHeight
            let dynamicIslandWidth = UIDevice.dynamicIslandWidth
            
            if hasDynamicIsland {
                // Device has Dynamic Island - position the extension directly attached to it
                pillView(
                    width: dynamicIslandWidth,
                    height: extensionHeight * 1.5,
                    position: CGPoint(x: geometry.size.width / 2, y: safeAreaInsets.top)
                )
            } else {
                // Device doesn't have Dynamic Island - position with 20pt padding from top
                pillView(
                    width: dynamicIslandWidth,
                    height: 37,
                    position: CGPoint(x: geometry.size.width / 2, y: 20 + 37 / 2)
                )
            }
        }
        .onAppear {
            // Get safe area insets
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                safeAreaInsets = EdgeInsets(
                    top: window.safeAreaInsets.top,
                    leading: window.safeAreaInsets.left,
                    bottom: window.safeAreaInsets.bottom,
                    trailing: window.safeAreaInsets.right
                )
            }
        }
    }
    
    @ViewBuilder
    private func pillView(width: CGFloat, height: CGFloat, position: CGPoint) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 18.5))
            
            VStack {
                Spacer()
                HStack {
                    Image("flower-nav")
                        .frame(width: 20, height: 20)
                    Text("123131")
                        .foregroundColor(.white)
                        .font(.montserat(size: 20, weight: .semibold))
                }
                .padding(.bottom, 3)
            }
        }
        .frame(width: width, height: height)
        .position(x: position.x, y: position.y / 1.3)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    DynamicIslandView()
}
