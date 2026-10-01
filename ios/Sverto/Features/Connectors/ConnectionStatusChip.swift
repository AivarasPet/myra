import SwiftUI

struct ConnectionStatusChip: View {
    let status: ConnectorStatus?

    private var label: String {
        switch status {
        case .active: "Active"
        case .pending, .pendingOauth: "Pending"
        case .error: "Needs attention"
        case .paused: "Paused"
        case .revoked: "Revoked"
        case nil: "Unknown"
        }
    }

    private var tint: Color {
        switch status {
        case .active: .gain
        case .pending, .pendingOauth: Color(.systemOrange)
        case .error: .loss
        case .paused, .revoked, nil: .secondary
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tint)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(tint.opacity(0.14), in: .capsule)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Status: \(label)")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        ConnectionStatusChip(status: .active)
        ConnectionStatusChip(status: .pendingOauth)
        ConnectionStatusChip(status: .error)
        ConnectionStatusChip(status: .paused)
        ConnectionStatusChip(status: nil)
    }
    .padding()
}
