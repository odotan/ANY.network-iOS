import SwiftUI

struct TestScreen: View {
    @State var gridModel: HiUScrollableHexGridModel = .init(numberOfCircles: 7)
    let cellSize: CGFloat = 100
    let spacing: CGFloat = 10

    // Array to store ColorPack for each cell.priority
    @State private var colorPacks: [ColorPack] = []

    // Adjustable ranges for color generation
    @State private var hue1Min: Double = 0.0
    @State private var hue1Max: Double = 0.6
    @State private var hue2Min: Double = 0.7
    @State private var hue2Max: Double = 1.0
    @State private var satMin: Double = 0.5
    @State private var satMax: Double = 1.0
    @State private var briMin: Double = 0.5
    @State private var briMax: Double = 1.0

    // Shadow adjustment sliders
    @State private var shadowHueOffset: Double = 0.03
    @State private var shadowSatDelta: Double = 0.15
    @State private var shadowBriDelta: Double = 0.25
    @State private var pressedBrightnessPercent: Double = 0.9

    // Modal presentation state
    @State private var showModal: Bool = false

    @State private var endHueDelta: Double = 0.04
    @State private var endSatDelta: Double = 0.07
    @State private var endBriDelta: Double = 0.07

    var body: some View {
        VStack {
            // Sliders for adjusting ranges
            Group {
                Text("Hue Range 1: \(String(format: "%.2f", hue1Min)) - \(String(format: "%.2f", hue1Max))")
                HStack {
                    Slider(value: $hue1Min, in: 0...hue1Max, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                    Slider(value: $hue1Max, in: hue1Min...1, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                }
                Text("Hue Range 2: \(String(format: "%.2f", hue2Min)) - \(String(format: "%.2f", hue2Max))")
                HStack {
                    Slider(value: $hue2Min, in: 0...hue2Max, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                    Slider(value: $hue2Max, in: hue2Min...1, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                }
                Text("Top Color Saturation Range: \(String(format: "%.2f", satMin)) - \(String(format: "%.2f", satMax))")
                HStack {
                    Slider(value: $satMin, in: 0...satMax, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                    Slider(value: $satMax, in: satMin...1, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                }
                Text("Top Color Brightness Range: \(String(format: "%.2f", briMin)) - \(String(format: "%.2f", briMax))")
                HStack {
                    Slider(value: $briMin, in: 0...briMax, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                    Slider(value: $briMax, in: briMin...1, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                }
            }
            .padding(.horizontal)
            .font(.caption)

            Group {
                Text("Bottom Color Hue Delta: ±\(String(format: "%.2f", endHueDelta))")
                Slider(value: $endHueDelta, in: 0...1, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                Text("Bottom Color Saturation Delta: ±\(String(format: "%.2f", endSatDelta))")
                Slider(value: $endSatDelta, in: 0...1, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
                Text("Bottom Color Brightness Delta: ±\(String(format: "%.2f", endBriDelta))")
                Slider(value: $endBriDelta, in: 0...1, step: 0.01, onEditingChanged: { _ in regenerateColorPacks() })
            }
            .padding(.horizontal)
            .font(.caption)

            Group {
                Text("InnerShadow Hue Offset: ±\(String(format: "%.2f", shadowHueOffset))")
                Slider(value: $shadowHueOffset, in: 0...1, step: 0.01, onEditingChanged: { _ in updateShadowProperties() })
                Text("InnerShadow Saturation Delta: \(String(format: "%.2f", shadowSatDelta))")
                Slider(value: $shadowSatDelta, in: 0...1, step: 0.01, onEditingChanged: { _ in updateShadowProperties() })
                Text("InnerShadow Brightness Delta: \(String(format: "%.2f", shadowBriDelta))")
                Slider(value: $shadowBriDelta, in: 0...1, step: 0.01, onEditingChanged: { _ in updateShadowProperties() })
                Text("Pressed Brightness: \(Int(pressedBrightnessPercent * 100))%")
                Slider(value: $pressedBrightnessPercent, in: 0.0...1.0, step: 0.01, onEditingChanged: { _ in updateShadowProperties() })
            }
            .padding(.horizontal)
            .font(.caption)

            Button("Go Full Screen") {
                showModal = true
            }
            .padding()
            .font(.headline)

            ScrollableHexGrid(viewModel: gridModel, content: { cell in
                let idx = cell.priority!
                let colorPack: ColorPack
                if colorPacks.indices.contains(idx) {
                    colorPack = colorPacks[idx]
                } else {
                    colorPack = ColorPack.random(
                        hueRanges: [(hue1Min...hue1Max), (hue2Min...hue2Max)],
                        saturationRange: satMin...satMax,
                        brightnessRange: briMin...briMax,
                        endHueDelta: endHueDelta,
                        endSatDelta: endSatDelta,
                        endBriDelta: endBriDelta,
                        shadowHueOffset: shadowHueOffset,
                        shadowSatDelta: shadowSatDelta,
                        shadowBriDelta: shadowBriDelta,
                        pressedBrightnessPercent: pressedBrightnessPercent
                    )
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
        .fullScreenCover(isPresented: $showModal) {
            ModalGridView(
                hue1Min: hue1Min, hue1Max: hue1Max,
                hue2Min: hue2Min, hue2Max: hue2Max,
                satMin: satMin, satMax: satMax,
                briMin: briMin, briMax: briMax,
                endHueDelta: endHueDelta,
                endSatDelta: endSatDelta,
                endBriDelta: endBriDelta,
                shadowHueOffset: shadowHueOffset,
                shadowSatDelta: shadowSatDelta,
                shadowBriDelta: shadowBriDelta,
                pressedBrightnessPercent: pressedBrightnessPercent,
                onClose: { showModal = false }
            )
        }
    }

    func update() {
        gridModel.refresh()
    }

    // Regenerate all ColorPacks (for top/bottom color changes)
    func regenerateColorPacks() {
        let count = gridModel.gridItems.count
        colorPacks = (0..<count).map { _ in
            ColorPack.random(
                hueRanges: [(hue1Min...hue1Max), (hue2Min...hue2Max)],
                saturationRange: satMin...satMax,
                brightnessRange: briMin...briMax,
                endHueDelta: endHueDelta,
                endSatDelta: endSatDelta,
                endBriDelta: endBriDelta,
                shadowHueOffset: shadowHueOffset,
                shadowSatDelta: shadowSatDelta,
                shadowBriDelta: shadowBriDelta,
                pressedBrightnessPercent: pressedBrightnessPercent
            )
        }
        update()
    }

    // Update only shadow properties for all ColorPacks (for shadow slider changes)
    func updateShadowProperties() {
        colorPacks = colorPacks.enumerated().map { (idx, pack) in
            // Extract HSB from startColor
            let hsb = pack.startColor.hsbComponents ?? (hue: 0, saturation: 0, brightness: 0, opacity: 1)
            let shadowHue = (hsb.hue + Double.random(in: -shadowHueOffset...shadowHueOffset)).truncatingRemainder(dividingBy: 1.0)
            let shadowSaturation = min(max(hsb.saturation - Double.random(in: shadowSatDelta...shadowSatDelta), 0), 1)
            let shadowBrightness = min(max(hsb.brightness - Double.random(in: shadowBriDelta...shadowBriDelta), 0), 1)
            let innerShadow = Color(hue: shadowHue, saturation: shadowSaturation, brightness: shadowBrightness)
            let pressed = Color(
                hue: hsb.hue,
                saturation: hsb.saturation,
                brightness: max(min(hsb.brightness * pressedBrightnessPercent, 1), 0)
            )
            return ColorPack(
                startColor: pack.startColor,
                endColor: pack.endColor,
                innerShadow: innerShadow,
                pressed: pressed,
                pressedInnerShadow: Color(hex: "070710")!
            )
        }
        update()
    }
}

struct ModalGridView: View {
    let hue1Min: Double
    let hue1Max: Double
    let hue2Min: Double
    let hue2Max: Double
    let satMin: Double
    let satMax: Double
    let briMin: Double
    let briMax: Double
    let endHueDelta: Double
    let endSatDelta: Double
    let endBriDelta: Double
    let shadowHueOffset: Double
    let shadowSatDelta: Double
    let shadowBriDelta: Double
    let pressedBrightnessPercent: Double
    let onClose: () -> Void
    @State var gridModel: HiUScrollableHexGridModel = .init(numberOfCircles: 7)

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()
            ScrollableHexGrid(viewModel: gridModel, content: { cell in
                let colorPack = ColorPack.random(
                    hueRanges: [(hue1Min...hue1Max), (hue2Min...hue2Max)],
                    saturationRange: satMin...satMax,
                    brightnessRange: briMin...briMax,
                    endHueDelta: endHueDelta,
                    endSatDelta: endSatDelta,
                    endBriDelta: endBriDelta,
                    shadowHueOffset: shadowHueOffset,
                    shadowSatDelta: shadowSatDelta,
                    shadowBriDelta: shadowBriDelta,
                    pressedBrightnessPercent: pressedBrightnessPercent
                )
                return AnyView(TestHex(colorPack: colorPack))
            })
            .shadow(color: .black, radius: 40, x: 10, y: 10)
            .edgesIgnoringSafeArea(.all)
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.primary)
                    .padding()
            }
        }
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

    static var colors: [ColorPack] = {
        return [
            .init(
                startColor: Color(hex: "FDDD3B")!,
                endColor: Color(hex: "FFCC00")!,
                innerShadow: Color(hex: "BD8302")!,
                pressed: Color(hex: "1F4048")!,
                pressedInnerShadow: Color(hex: "070710")!
            ),
            .init(
                startColor: Color(hex: "3BFD92")!,
                endColor: Color(hex: "05B497")!,
                innerShadow: Color(hex: "BD8302")!,
                pressed: Color(hex: "1F4048")!,
                pressedInnerShadow: Color(hex: "070710")!
            ),
            .init(
                startColor: Color(hex: "FD3BD9")!,
                endColor: Color(hex: "FF4A4A")!,
                innerShadow: Color(hex: "BD8302")!,
                pressed: Color(hex: "1F4048")!,
                pressedInnerShadow: Color(hex: "070710")!
            ),
            .init(
                startColor: Color(hex: "A3B9FF")!,
                endColor: Color(hex: "00B2FF")!,
                innerShadow: Color(hex: "BD8302")!,
                pressed: Color(hex: "1F4048")!,
                pressedInnerShadow: Color(hex: "070710")!
            )
        ]
    }()

    static func random(
        hueRanges: [ClosedRange<Double>] = [0...1],
        saturationRange: ClosedRange<Double> = 0.5...1,
        brightnessRange: ClosedRange<Double> = 0.5...1,
        endHueDelta: Double = 0.04,
        endSatDelta: Double = 0.07,
        endBriDelta: Double = 0.07,
        shadowHueOffset: Double = 0.03,
        shadowSatDelta: Double = 0.15,
        shadowBriDelta: Double = 0.25,
        pressedBrightnessPercent: Double = 0.9
    ) -> ColorPack {
        // Pick a random hue range
        let chosenRange = hueRanges.randomElement() ?? (0...1)
        let baseHue = Double.random(in: chosenRange)
        let baseSaturation = Double.random(in: saturationRange)
        let baseBrightness = Double.random(in: brightnessRange)
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
