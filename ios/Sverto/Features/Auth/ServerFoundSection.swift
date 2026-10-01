import SwiftUI
import SvertoCore

struct ServerFoundSection: View {
    let url: String
    let info: ServerInfo
    let onUseDifferentAddress: () -> Void

    private var versionText: String {
        let version = info.version.trimmingCharacters(in: .whitespacesAndNewlines)
        return version.isEmpty ? "Unknown" : version
    }

    var body: some View {
        Section {
            LabeledContent {
                Text(url)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            } label: {
                Label("Server address", systemImage: "server.rack")
            }
            LabeledContent {
                Text(versionText)
                    .monospacedDigit()
            } label: {
                Label("Version", systemImage: "shippingbox")
            }
            LabeledContent {
                Text(info.authMode.displayLabel)
            } label: {
                Label("Sign-in method", systemImage: "key.fill")
            }
            Button("Use a different address", action: onUseDifferentAddress)
        }
    }
}
