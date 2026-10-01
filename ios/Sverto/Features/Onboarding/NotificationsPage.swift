import SwiftUI
import UIKit

struct NotificationsPage: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var permission: NotificationPermission = .notRequested

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                content
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }
        .task { permission = await NotificationPermission.current() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { permission = await NotificationPermission.current() }
            }
        }
    }

    private var content: some View {
        VStack(spacing: 32) {
            Image(systemName: permission == .granted ? "bell.badge.fill" : "bell.fill")
                .font(.largeTitle.weight(.medium))
                .imageScale(.large)
                .foregroundStyle(.tint)
                .frame(width: 96, height: 96)
                .background(Color.accentColor.opacity(0.15), in: .circle)
                .accessibilityHidden(true)
            VStack(spacing: 16) {
                Text("Stay informed")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text("Get notifications for transaction confirmations, portfolio alerts, and Myra AI updates.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .fixedSize(horizontal: false, vertical: true)
            statusView
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch permission {
        case .granted:
            Label("Notifications enabled", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.tint)
        case .denied, .notRequested:
            VStack(spacing: 12) {
                Button {
                    Task { await enableNotifications() }
                } label: {
                    Label("Enable notifications", systemImage: "bell.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                if permission == .denied {
                    Text("No problem — you can turn notifications on later in Settings.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private func enableNotifications() async {
        switch permission {
        case .notRequested:
            permission = await NotificationPermission.request()
        case .denied:
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                openURL(settingsUrl)
            }
        case .granted:
            break
        }
    }
}
