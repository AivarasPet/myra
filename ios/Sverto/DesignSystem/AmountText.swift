import SwiftUI

struct AmountText: View {
    private let text: String
    private let style: Font.TextStyle
    private let signedColor: Bool

    init(_ text: String, style: Font.TextStyle = .body, signedColor: Bool = false) {
        self.text = text
        self.style = style
        self.signedColor = signedColor
    }

    private var color: Color {
        guard signedColor else { return .primary }
        return text.hasPrefix("-") ? .loss : .gain
    }

    var body: some View {
        Text(text)
            .font(.system(style))
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
    }
}

#Preview {
    VStack(alignment: .trailing) {
        AmountText("$46,890.69", style: .title2)
        AmountText("+£1,500.00", signedColor: true)
        AmountText("-£15.34", style: .caption, signedColor: true)
    }
    .padding()
}
