import SwiftUI

struct TransientKeySheet: View {
    let onSave: (String) -> Void
    let onDismiss: () -> Void
    @State private var key = ""
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(onSave: @escaping (String) -> Void, onDismiss: @escaping () -> Void) {
        self.onSave = onSave
        self.onDismiss = onDismiss
    }

    private var canSave: Bool {
        !key.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("This key is stored only on this device. Syncs run while the app is open; set the key up again on any other device you use.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .listRowBackground(Color.clear)
                }
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API key")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        SecureField("API key", text: $key)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .onSubmit {
                                if canSave { onSave(key) }
                            }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Trading 212 API key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
            .safeAreaInset(edge: .bottom) {
                ConnectorHeroButton(title: "Save and sync") { onSave(key) }
                    .disabled(!canSave)
            }
        }
        .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.medium, .large])
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        TransientKeySheet(onSave: { _ in }, onDismiss: {})
    }
}
