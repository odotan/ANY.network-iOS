import SwiftUI

struct TestScreen: View {
    @State var gridModel: HiUScrollableHexGridModel = .init(numberOfCircles: 7)
    let cellSize: CGFloat = 100
    let spacing: CGFloat = 10

    // Array to store ColorPack for each cell.priority
    @State private var colorPacks: [ColorPack] = []

    var body: some View {
        ScrollableHexGrid(viewModel: gridModel, content: { cell in
            let idx = cell.priority!
            let colorPack: ColorPack
            if colorPacks.indices.contains(idx) {
                colorPack = colorPacks[idx]
            } else {
                colorPack = ColorPack.random()
            }
            return AnyView(TestHex(colorPack: colorPack))
        })
        .shadow(color: .black, radius: 40, x: 10, y: 10)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gridModel.recenter()
            }
            regenerateColorPacks()
        }
    }

    func update() {
        gridModel.refresh()
    }

    // Regenerate all ColorPacks (for top/bottom color changes)
    func regenerateColorPacks() {
        let count = gridModel.gridItems.count
        colorPacks = (0..<count).map { _ in
            ColorPack.random()
        }
        update()
    }
}

struct TestHex: View {
    let colorPack: ColorPack
    @State var isSelected = false
    var body: some View {
        
        Button {
            withAnimation {
                isSelected.toggle()
            }
        } label: {
            if !isSelected {
                normalState
            } else {
                selectedState
            }
        }
    }

    @ViewBuilder
    var normalState: some View {
        HexagonShape(cornerRadius: 6)
            .foregroundStyle(
                LinearGradient(
                    colors: [colorPack.startColor, colorPack.endColor],
                    startPoint: .init(x: 0, y: 0),
                    endPoint: .init(x: 0, y: 1)
                )
                .shadow(.inner(color: .white.opacity(0.5), radius: 8.5, x: 0, y: 8.5))
                .shadow(.inner(color: colorPack.innerShadow.opacity(0.7), radius: 4.2, x: 0, y: -4))
            )
    }
    
    @ViewBuilder
    var selectedState: some View {
        HexagonShape(cornerRadius: 6)
            .foregroundStyle(
                colorPack.pressed
                    .shadow(.inner(color: .white.opacity(0.1), radius: 8.5, x: -8.5, y: -8.5))
                    .shadow(.inner(color: colorPack.pressedInnerShadow, radius: 8.5, x: 8.5, y: 8.5))
            )
    }
}

struct ColorPack {
    let startColor: Color
    let endColor: Color
    let innerShadow: Color
    let pressed: Color
    let pressedInnerShadow: Color
    
    static let hue1Min: Double = 0.0
    static let hue1Max: Double = 0.6
    static let hue2Min: Double = 0.75
    static let hue2Max: Double = 1.0
    static let satMin: Double = 0.6
    static let satMax: Double = 1.0
    static let briMin: Double = 0.6
    static let briMax: Double = 1.0

    static let shadowHueOffset: Double = 0.0
    static let shadowSatDelta: Double = 0.05
    static let shadowBriDelta: Double = 0.75
    static let pressedBrightnessPercent: Double = 0.25

    static let showModal: Bool = false

    static let endHueDelta: Double = 0.0
    static let endSatDelta: Double = 0.05
    static let endBriDelta: Double = 0.05
    
    static func random() -> ColorPack {
        // Pick a random hue range
        let hueRanges = [(hue1Min...hue1Max), (hue2Min...hue2Max)]
        let chosenRange = hueRanges.randomElement() ?? (0...1)
        let baseHue = Double.random(in: chosenRange)
        let baseSaturation = Double.random(in: satMin...satMax)
        let baseBrightness = Double.random(in: briMin...briMax)
        let startColor = Color(hue: baseHue, saturation: baseSaturation, brightness: baseBrightness)
        // Slightly vary the base color for the end color
        let endColor = Color(
            hue: (baseHue + Double.random(in: -endHueDelta...endHueDelta)).truncatingRemainder(dividingBy: 1.0),
            saturation: min(max(baseSaturation + Double.random(in: -endSatDelta...endSatDelta), 0), 1),
            brightness: min(max(baseBrightness + Double.random(in: -endBriDelta...endBriDelta), 0), 1)
        )
        // Generate a natural innerShadow color
        let baseHSB = startColor.hsbComponents ?? (hue: baseHue, saturation: baseSaturation, brightness: baseBrightness, opacity: 1)
        let shadowHue = (baseHSB.hue + Double.random(in: -shadowHueOffset...shadowHueOffset)).truncatingRemainder(dividingBy: 1.0)
        let shadowSaturation = min(max(baseHSB.saturation - Double.random(in: shadowSatDelta...shadowSatDelta), 0), 1)
        let shadowBrightness = min(max(baseHSB.brightness - Double.random(in: shadowBriDelta...shadowBriDelta), 0), 1)
        let innerShadow = Color(hue: shadowHue, saturation: shadowSaturation, brightness: shadowBrightness)
        let pressed = Color(
            hue: baseHSB.hue,
            saturation: baseHSB.saturation,
            brightness: max(min(baseHSB.brightness * pressedBrightnessPercent, 1), 0)
        )
        return ColorPack(
            startColor: startColor,
            endColor: endColor,
            innerShadow: innerShadow,
            pressed: pressed,
            pressedInnerShadow: Color(hex: "070710")!
        )
    }
}
