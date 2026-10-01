import SvertoCore
import SwiftUI

struct BindingSetupScreen: View {
    let connectionId: String
    @Environment(AppServices.self) private var services

    var body: some View {
        BindingSetupContent(store: services.store, connectionId: connectionId)
    }
}

private struct LinkTarget: Identifiable {
    let account: ProviderAccount
    var id: String { account.providerAccountId }
}

private struct BindingSetupContent: View {
    @State private var model: BindingSetupViewModel
    @State private var linkTarget: LinkTarget?
    @Environment(ShellState.self) private var shell
    private let connectionId: String

    init(store: AppStore, connectionId: String) {
        _model = State(initialValue: BindingSetupViewModel(store: store, connectionId: connectionId))
        self.connectionId = connectionId
    }

    var body: some View {
        List {
            Section {
                Text("Choose which Sverto account each imported account writes into. You can skip any and add them later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .listRowBackground(Color.clear)
            }
            Section("Accounts") {
                if let error = model.loadError {
                    FormErrorRow(message: error)
                }
                if model.loading, model.providerAccounts.isEmpty {
                    BindingRowsSkeleton()
                } else if model.providerAccounts.isEmpty, model.loadError == nil {
                    Text("No provider accounts available.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.providerAccounts, id: \.providerAccountId) { account in
                        ProviderAccountRow(
                            account: account,
                            boundName: model.boundAccounts[account.providerAccountId],
                            onOpen: {
                                shell.push(.providerAccountDetail(
                                    connectionId: connectionId,
                                    providerAccountId: account.providerAccountId,
                                    displayName: account.displayName,
                                    currency: account.currency
                                ))
                            },
                            onLink: { linkTarget = LinkTarget(account: account) }
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Link accounts")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            ConnectorHeroButton(title: "Done") { shell.pop() }
        }
        .task { await model.load() }
        .refreshable { await model.load() }
        .toastOnError(model.error)
        .sheet(item: $linkTarget) { target in
            BindingAccountPickerSheet(accounts: model.svertoAccounts) { sverto in
                Task { await model.bind(providerAccountId: target.account.providerAccountId, svertoAccountId: sverto.id) }
            }
        }
    }
}

private struct ProviderAccountRow: View {
    let account: ProviderAccount
    let boundName: String?
    let onOpen: () -> Void
    let onLink: () -> Void

    private var subtitle: String {
        boundName.map { "Linked to \($0)" } ?? account.currency ?? "Not linked"
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ConnectorNames.humanizeAccountName(account.displayName))
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(.rect)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.primary)
            .accessibilityHint("Shows this account's transactions")
            if boundName != nil {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
                    .accessibilityLabel("Linked")
            } else {
                Button(action: onLink) {
                    Text("Link")
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityLabel("Link \(ConnectorNames.humanizeAccountName(account.displayName))")
            }
        }
    }
}
