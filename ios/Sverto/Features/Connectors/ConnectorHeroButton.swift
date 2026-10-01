import SwiftUI

struct ConnectorHeroButton: View {
    let title: String
    var systemImage: String? = nil
    var isBusy = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isBusy {
                    ProgressView()
                        .tint(.onAccent)
                } else if let systemImage {
                    Label {
                        Text(title)
                            .foregroundStyle(Color.onAccent)
                    } icon: {
                        Image(systemName: systemImage)
                            .foregroundStyle(Color.onAccent)
                    }
                    .fontWeight(.semibold)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.onAccent)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 28)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .accessibilityLabel(title)
        .accessibilityValue(isBusy ? "In progress" : "")
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 16) {
        ConnectorHeroButton(title: "Connect", systemImage: ConnectorCatalog.fallbackSystemImage) {}
        ConnectorHeroButton(title: "Done") {}
        ConnectorHeroButton(title: "Connect", isBusy: true) {}
    }
    .background(.screenBackground)
}
