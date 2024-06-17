import SwiftUI

struct ToggleSwitch: View {
    @Binding private var isActive: Bool
    private var text: String

    init(isActive: Binding<Bool>, text: String) {
        self._isActive = isActive
        self.text = text
    }

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Button(action: {
                    withAnimation(.linear(duration: 0.15)) {
                        self.isActive.toggle()
                    }
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isActive ? .appToggleActiveGreen : .appToggleGray)
                        .frame(width: 63, height: 39)
                        .overlay(alignment: .leading) {
                            Circle()
                                .fill(isActive ? .appGreen : .appGray)
                                .frame(width: 25, height: 25)
                                .padding(7)
                                .offset(x: isActive ? 25 : 0)
                        }
                }
                .buttonStyle(ToggleSwitchButtonStyle())
            }

            Text(text)
                .font(.custom(Font.montseratRegular, size: 16))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        VStack(spacing: 24) {
            ToggleSwitch(isActive: .constant(true), text: "Make this information available\non my public Profile")
            ToggleSwitch(isActive: .constant(false), text: "Make this information publicly\nSearchable")
        }
    }
}

private struct ToggleSwitchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
    }
}
