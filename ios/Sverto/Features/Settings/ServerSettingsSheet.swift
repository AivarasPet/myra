import SvertoCore
import SwiftUI

struct ServerSettingsSheet: View {
    let serverUrl: String
    let version: String
    let authMode: AuthMode
    let onSwitchServer: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Server URL", value: serverUrl)
                        .textSelection(.enabled)
                    LabeledContent("Version", value: version.isEmpty ? "Unknown" : version)
                    LabeledContent("Authentication", value: authMode.displayLabel)
                }
                Section {
                    Button("Switch server", action: onSwitchServer)
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
