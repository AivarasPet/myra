import SvertoCore
import SwiftUI

struct ProviderAccountDetailScreen: View {
    let connectionId: String
    let providerAccountId: String
    let displayName: String
    let currency: String?
    @Environment(AppServices.self) private var services

    var body: some View {
        ProviderAccountDetailContent(
            store: services.store,
            connectionId: connectionId,
            providerAccountId: providerAccountId,
            displayName: displayName,
            currency: currency
        )
    }
}

private struct ProviderAccountDetailContent: View {
    @State private var model: ProviderAccountDetailViewModel
    @State private var isPickingAccount = false
    @Environment(ShellState.self) private var shell
    private let displayName: String
    private let currency: String?

    init(store: AppStore, connectionId: String, providerAccountId: String, displayName: String, currency: String?) {
        _model = State(initialValue: ProviderAccountDetailViewModel(
            store: store,
            connectionId: connectionId,
            providerAccountId: providerAccountId
        ))
        self.displayName = displayName
        self.currency = currency
    }

    private var statusLine: String {
        let linked = model.linkedTo.map { "Linked to \($0)" } ?? "Not linked"
        return [currency, linked].compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        List {
            Section {
                Text(statusLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                if let error = model.error {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .listRowBackground(Color.clear)
                }
            }
            if model.loading, model.transactions.isEmpty {
                Section { BindingRowsSkeleton() }
            } else if model.transactions.isEmpty, model.error == nil {
                Section {
                    EmptyState(
                        title: "No transactions fetched yet",
                        systemImage: "tray",
                        description: "Transactions appear here after this account's history has been fetched."
                    )
                    .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    ForEach(Array(model.transactions.enumerated()), id: \.offset) { _, transaction in
                        TransactionPreviewRow(transaction: transaction)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(ConnectorNames.humanizeAccountName(displayName))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if !model.loading, model.linkedTo == nil {
                ConnectorHeroButton(title: "Link account") { isPickingAccount = true }
            }
        }
        .task { await model.load() }
        .refreshable { await model.load() }
        .sheet(isPresented: $isPickingAccount) {
            BindingAccountPickerSheet(accounts: model.svertoAccounts) { sverto in
                let owner = shell.navigationOwner
                Task {
                    if await model.bind(svertoAccountId: sverto.id) {
                        shell.pop(in: owner)
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: model.justLinked) { _, justLinked in justLinked }
    }
}

private struct TransactionPreviewRow: View {
    let transaction: ProviderAccountTransaction
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var description: String {
        let trimmed = transaction.description.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "(no description)" : transaction.description
    }

    private var detail: String {
        var parts = [ConnectorTimeFormat.absoluteDate(transaction.date)]
        if let quantity = transaction.quantity, let asset = transaction.assetIdentifier {
            parts.append("\(ConnectorNames.quantity(quantity)) × \(asset)")
        }
        return parts.joined(separator: " · ")
    }

    private var amount: String {
        Money.format(transaction.amount, ticker: transaction.currency, signed: true)
    }

    var body: some View {
        contentLayout {
            VStack(alignment: .leading, spacing: 2) {
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 8)
            }
            AmountText(amount)
                .layoutPriority(1)
                .accessibilityValue(transaction.currency)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    private var contentLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 12))
    }
}
