import SwiftUI

enum PanelVariant {
    case primary
    case secondary

    var tint: Color {
        switch self {
        case .primary: .brand
        case .secondary: .indigo
        }
    }
}

struct DirectionBadge: View {
    let label: String
    let sign: AmountSign
    let variant: PanelVariant

    private var symbol: String? {
        switch sign {
        case .positive: "arrow.down"
        case .negative: "arrow.up"
        case .any: nil
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.caption.weight(.bold))
                    .accessibilityHidden(true)
            }
            Text(label)
                .font(.footnote.weight(.semibold))
        }
        .foregroundStyle(variant.tint)
        .textCase(.uppercase)
    }
}

struct SwapGlyph: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "arrow.up.arrow.down")
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 40, height: 40)
                .background(.cardFill, in: .circle)
                .overlay(Circle().strokeBorder(Color(.separator), lineWidth: 1))
                .accessibilityHidden(true)
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}
