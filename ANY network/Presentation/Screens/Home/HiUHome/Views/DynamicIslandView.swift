//
//  DynamicIslandView.swift
//  ANY network
//
//  Created by Danail Vrachev on 30.07.25.
//

import SwiftUI

// MARK: - Flying Points Coordinator
class FlyingPointsCoordinator: ObservableObject {
    @Published var totalPoints: Int = 0
    @Published var isPulsing: Bool = false
    @Published var flyingPoints: [FlyingPoint] = []
    
    func triggerFlyingPoints(points: Int, from startPosition: CGPoint, to endPosition: CGPoint) {
        let flyingPoint = FlyingPoint(
            points: points,
            startPosition: startPosition,
            endPosition: endPosition,
            currentPosition: startPosition
        )
        
        flyingPoints.append(flyingPoint)
        
        // Animate the point flying to the destination
        withAnimation(.easeInOut(duration: 1.2)) {
            if let index = flyingPoints.firstIndex(where: { $0.id == flyingPoint.id }) {
                flyingPoints[index].currentPosition = endPosition
                flyingPoints[index].opacity = 0.8
                flyingPoints[index].scale = 0.8
            }
        }
        
        // Remove the point after animation and add to total
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if let index = self.flyingPoints.firstIndex(where: { $0.id == flyingPoint.id }) {
                let points = self.flyingPoints[index].points
                self.flyingPoints.remove(at: index)
                self.addPoints(points)
            }
        }
    }
    
    private func addPoints(_ points: Int) {
        totalPoints += points
        
        // Trigger pulse animation
        isPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isPulsing = false
        }
    }
}

// MARK: - Flying Point Model
struct FlyingPoint: Identifiable {
    let id = UUID()
    let points: Int
    let startPosition: CGPoint
    let endPosition: CGPoint
    var currentPosition: CGPoint
    var opacity: Double = 1.0
    var scale: Double = 1.0
}

// MARK: - Flying Points Overlay
struct FlyingPointsOverlay: View {
    @ObservedObject var coordinator: FlyingPointsCoordinator
    
    var body: some View {
        ZStack {
            ForEach(coordinator.flyingPoints) { point in
                Text("+\(point.points)")
                    .font(.montserat(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.appGreen)
                            .frame(width: 32, height: 32)
                    )
                    .position(point.currentPosition)
                    .opacity(point.opacity)
                    .scaleEffect(point.scale)
            }
        }
    }
}

struct DynamicIslandView: View {
    @State private var safeAreaInsets: EdgeInsets = .init()
    @ObservedObject var coordinator: FlyingPointsCoordinator
    
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
                    Text("\(coordinator.totalPoints)")
                        .foregroundColor(.white)
                        .font(.montserat(size: 20, weight: .semibold))
                        .scaleEffect(coordinator.isPulsing ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: coordinator.isPulsing)
                }
                .padding(.bottom, 3)
            }
        }
        .frame(width: width, height: height)
        .position(x: position.x, y: position.y / 1.3)
        .edgesIgnoringSafeArea(.all)
    }
    
    func triggerFlyingPoints(points: Int, from startPosition: CGPoint) {
        // Calculate the end position (Dynamic Island position)
        let endPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: safeAreaInsets.top)
        coordinator.triggerFlyingPoints(points: points, from: startPosition, to: endPosition)
    }
}

#Preview {
    DynamicIslandView(coordinator: FlyingPointsCoordinator())
}
