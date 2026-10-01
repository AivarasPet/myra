import SwiftUI

struct ServerUrlScreen: View {
    let lastUrl: String
    let status: ServerConnectionStatus

    @Environment(SessionCoordinator.self) private var session
    @State private var url: String
    @FocusState private var isUrlFocused: Bool

    private struct AutoCheckTrigger: Equatable {
        let url: String
        let status: ServerConnectionStatus
    }

    init(lastUrl: String, status: ServerConnectionStatus) {
        self.lastUrl = lastUrl
        self.status = status
        _url = State(initialValue: lastUrl)
    }

    private var normalizedUrl: String {
        var trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmed.hasSuffix("/") { trimmed.removeLast() }
        return trimmed
    }

    private var currentStatus: ServerConnectionStatus { status.scoped(to: normalizedUrl) }
    private var isValidUrl: Bool { SessionCoordinator.isPlausibleServerUrl(normalizedUrl) }
    private var canSubmit: Bool { isValidUrl && !currentStatus.isChecking }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    AuthHeader(title: currentStatus.title, description: currentStatus.description, tint: currentStatus.heroTint) {
                        if let symbol = currentStatus.heroSystemImage {
                            Image(systemName: symbol)
                        } else {
                            ProgressView()
                                .controlSize(.large)
                        }
                    }
                }
                if case let .found(foundUrl, info) = currentStatus {
                    ServerFoundSection(url: foundUrl, info: info) { url = "" }
                } else {
                    Section("Server URL") {
                        urlField
                    }
                }
                if case let .error(_, message) = currentStatus {
                    Section {
                        FormErrorRow(message: message)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { session.showWelcome() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                ProminentActionButton(title: currentStatus.primaryButtonTitle, action: primaryAction)
                    .disabled(!canSubmit)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .task(id: AutoCheckTrigger(url: normalizedUrl, status: currentStatus)) { await autoCheck() }
        }
    }

    private var urlField: some View {
        HStack(spacing: 10) {
            Image(systemName: "link")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("Server URL", text: $url, prompt: Text(verbatim: "https://finance.example.com"))
                .keyboardType(.URL)
                .textContentType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .focused($isUrlFocused)
                .onSubmit(primaryAction)
                .disabled(currentStatus.isChecking)
            if !url.isEmpty && !currentStatus.isChecking {
                Button {
                    url = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(.rect)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Clear server URL")
            }
        }
    }

    private func primaryAction() {
        guard canSubmit else { return }
        isUrlFocused = false
        if currentStatus.isFound {
            session.continueWithSelfHosted()
        } else {
            session.checkSelfHostedServer(normalizedUrl)
        }
    }

    private func autoCheck() async {
        guard currentStatus == .idle, isValidUrl else { return }
        try? await Task.sleep(for: .milliseconds(700))
        guard !Task.isCancelled else { return }
        isUrlFocused = false
        session.checkSelfHostedServer(normalizedUrl)
    }
}
