import SwiftUI

struct AssetListRow: View {
    let ticker: String
    let name: String
    let supportingText: String
    var selected = false
    var showsDisclosure = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 12) {
            Monogram(text: ticker, tint: selected ? .accentColor : .secondary)
                .dynamicTypeSize(dynamicTypeSize.isAccessibilitySize ? .large : dynamicTypeSize)
            VStack(alignment: .leading, spacing: 2) {
                Text(ticker.isEmpty ? name : ticker)
                    .font(.body.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Text(supportingText)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
                    .accessibilityLabel("Selected")
            }
            if showsDisclosure {
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(Color.primary)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

#Preview {
    List {
        AssetListRow(ticker: "AAPL", name: "Apple Inc.", supportingText: "Apple Inc.")
        AssetListRow(ticker: "BTC", name: "Bitcoin", supportingText: "Bitcoin · Crypto", selected: true)
        AssetListRow(ticker: "", name: "Unnamed", supportingText: "Unnamed")
    }
}
