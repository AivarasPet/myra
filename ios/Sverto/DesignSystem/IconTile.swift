import SwiftUI

enum IconTileShape {
    case roundedRect
    case circle
}

struct IconTile<Glyph: View>: View {
    private let tint: Color
    private let shape: IconTileShape
    private let glyphFont: Font
    private let glyph: (CGFloat) -> Glyph
    @ScaledMetric private var size: CGFloat

    init(
        tint: Color = .brand,
        size: CGFloat = Layout.rowGlyphSize,
        shape: IconTileShape = .roundedRect,
        @ViewBuilder glyph: @escaping (CGFloat) -> Glyph
    ) {
        self.tint = tint
        self.shape = shape
        self.glyph = glyph
        glyphFont = Self.glyphFont(forTileSize: size)
        _size = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    var body: some View {
        glyph(size)
            .font(glyphFont)
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(Layout.iconTileOpacity), in: backgroundShape)
            .accessibilityHidden(true)
    }

    private var backgroundShape: AnyShape {
        switch shape {
        case .roundedRect: AnyShape(.rect(cornerRadius: size * 0.3, style: .continuous))
        case .circle: AnyShape(.circle)
        }
    }

    private static func glyphFont(forTileSize size: CGFloat) -> Font {
        switch size {
        case ..<44: .body.weight(.medium)
        case ..<64: .title2.weight(.medium)
        default: .largeTitle.weight(.medium)
        }
    }
}

extension IconTile where Glyph == Image {
    init(systemImage: String, tint: Color = .brand, size: CGFloat = Layout.rowGlyphSize, shape: IconTileShape = .roundedRect) {
        self.init(tint: tint, size: size, shape: shape) { _ in
            Image(systemName: systemImage)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        IconTile(systemImage: "cart")
        IconTile(systemImage: "building.columns", tint: .orange, size: 48, shape: .circle)
        IconTile(size: 56) { side in LucideIcon(name: "shopping-cart", size: side / 2) }
    }
    .padding()
}
