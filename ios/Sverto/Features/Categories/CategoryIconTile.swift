import SwiftUI

struct CategoryIconTile: View {
    let icon: String
    var size: CGFloat = 40

    var body: some View {
        LucideIcon(name: icon, size: size / 2, color: .brand)
            .frame(width: size, height: size)
            .background(Color.brand.opacity(0.14), in: .rect(cornerRadius: size * 0.3, style: .continuous))
    }
}

#Preview {
    HStack(spacing: 16) {
        CategoryIconTile(icon: "shopping-cart")
        CategoryIconTile(icon: "tag", size: 56)
    }
    .padding()
}
