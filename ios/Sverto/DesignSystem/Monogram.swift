import SwiftUI

struct Monogram: View {
    private let letters: String
    private let size: CGFloat
    private let tint: Color

    init(text: String, size: CGFloat = 44, tint: Color = .brand) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        letters = trimmed.isEmpty ? "—" : String(trimmed.prefix(3)).uppercased()
        self.size = size
        self.tint = tint
    }

    var body: some View {
        IconTile(tint: tint, size: size, shape: .circle) { _ in
            Text(letters)
                .font(.callout.weight(.semibold))
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 4)
        }
    }
}

#Preview {
    HStack {
        Monogram(text: "AAPL")
        Monogram(text: "btc", size: 56)
        Monogram(text: "", tint: .secondary)
    }
    .padding()
}
