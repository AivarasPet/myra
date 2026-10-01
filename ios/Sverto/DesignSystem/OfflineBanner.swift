import SwiftUI
import SvertoCore

struct OfflineBanner: View {
    @Environment(ConnectionStatusModel.self) private var connection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            if let text = connection.bannerText {
                Label(text, systemImage: connection.status == .deviceOffline ? "wifi.slash" : "cloud.slash")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: .capsule)
                    .padding(.vertical, 4)
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .animation(reduceMotion ? nil : .snappy, value: connection.status)
    }
}
