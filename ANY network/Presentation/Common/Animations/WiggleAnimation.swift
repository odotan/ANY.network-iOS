import SwiftUI

extension View {
    public func wiggle(wiggle: Bool = true, rotationAngle: CGFloat, offset: CGFloat = 0.8) -> some View {
        modifier(WiggleModifier(wiggle: wiggle, rotation: rotationAngle, offset: offset))
    }
}

private struct WiggleModifier: ViewModifier {
  let rotation: CGFloat
  let offset: CGFloat
  
  let wiggle: Bool
  
  init(wiggle: Bool, rotation: CGFloat, offset: CGFloat) {
    self.wiggle = wiggle
    self.rotation = rotation
    self.offset = offset
  }
  
  init(wiggle: Bool, size: CGSize, rotationTravel: CGFloat, offset: CGFloat) {
    self.wiggle = wiggle
    
    // Calculate the distance from the center to a corner (radius of the rectangle)
    let radius = sqrt(pow(size.width / 2, 2) + pow(size.height / 2, 2))
    
    // The target distance traveled by the corner
    let targetDistance = rotationTravel
    
    // Use the formula to calculate the angle in radians: d = 2 * r * sin(θ/2)
    // Rearranged: θ = 2 * arcsin(d / (2 * r))
    let angleRadians = 2 * asin(targetDistance / (2 * radius))
    
    // Convert radians to degrees
    let angleDegrees = angleRadians * 180 / .pi
    self.rotation = angleDegrees
    
    self.offset = offset
  }

  @State private var triggered: Bool = false
  @State private var reversed: Bool = false
  
  private var offsetAmount: CGFloat {
    if (!wiggle || !triggered) {
      return 0.0
    }

    return offset
  }
  
  private var offsetAnimation: Animation {
    if (!wiggle) {
      return
        .easeInOut(duration: 0.14)
    } else {
      return
        .easeInOut(duration: randomize(interval: 0.14, withVariance: 0.009))
        .repeatForever(autoreverses: true)
        .delay(randomize(interval: 0.07, withVariance: 0.07))
    }
  }
  
  private var rotateAmount: CGFloat {
    if (!wiggle) {
      return 0
    }
    // The reason we multiply by (-)2 here is because we'll counter rotate by a
    // a factor of one in another non-repeating animation. This way we can have a
    // full left-to-right wiggle (-1 to 1) rather that a half (-1 to 0 or 1 to 0)
    if (triggered) {
      if (reversed) {
        return rotation * -2
      }
      return rotation * 2
    }
    return 0
  }
  
  private var rotateAnimation: Animation {
    if (!wiggle) {
      return
        .easeInOut(duration: 0.12)
    } else {
      return
        .easeInOut(duration: randomize(interval: 0.12, withVariance: 0.009))
        .repeatForever(autoreverses: true)
        .delay(randomize(interval: 0.06, withVariance: 0.06))
    }
  }

  func body(content: Content) -> some View {
    content
      .animation(offsetAnimation) {
        $0.projectionOffset(x: 0, y: offsetAmount)
      }
      .animation(rotateAnimation) {
        $0.rotationEffect(.degrees(rotateAmount), anchor: .center)
      }
      .animation(.easeInOut(duration: 0.12)
          .delay(0.06)) {
        $0.rotationEffect(.degrees(wiggle ? (reversed ? rotation : -rotation): 0), anchor: .center)
      }
      .onAppear {
        // We changed this here so that the animation runs even if it starts with `wiggle == true`
        if (wiggle) {
          triggered = true
        }
      }
      .onDisappear {
        if (wiggle) {
          triggered = false
        }
      }
      .onChange(of: wiggle) {
        triggered = wiggle
        reversed = Bool.random()
      }
  }

  private func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
    interval + variance * (Double.random(in: -1...1))
  }
}

extension View {
    func projectionOffset(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        self.projectionOffset(.init(x: x, y: y))
    }

    func projectionOffset(_ translation: CGPoint) -> some View {
        modifier(ProjectionOffsetEffect(translation: translation))
    }
}

private struct ProjectionOffsetEffect: GeometryEffect {
    var translation: CGPoint
    var animatableData: CGPoint.AnimatableData {
        get { translation.animatableData }
        set { translation = .init(x: newValue.first, y: newValue.second) }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        .init(CGAffineTransform(translationX: translation.x, y: translation.y))
    }
}
