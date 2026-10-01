import SwiftUI

struct ProviderAvatar: View {
    let systemImage: String
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.brand)
            .frame(width: size, height: size)
            .background(Color.brand.opacity(0.16), in: .rect(cornerRadius: size * 0.3, style: .continuous))
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 16) {
        ProviderAvatar(systemImage: ConnectorCatalog.bankSystemImage, size: 44)
        ProviderAvatar(systemImage: ConnectorCatalog.brokerSystemImage)
        ProviderAvatar(systemImage: ConnectorCatalog.fallbackSystemImage, size: 64)
    }
    .padding()
}
