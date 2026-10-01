import SvertoCore
import SwiftUI

struct AccountTransactionsScreen: View {
    let accountId: String

    @Environment(AppServices.self) private var services

    var body: some View {
        AccountTransactionsList(store: services.store, accountId: accountId)
    }
}

private struct AccountTransactionsList: View {
    @State private var model: AccountTransactionsViewModel
    @Environment(ShellState.self) private var shell

    init(store: AppStore, accountId: String) {
        _model = State(initialValue: AccountTransactionsViewModel(store: store, accountId: accountId))
    }

    var body: some View {
        content
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .task { await model.start() }
            .onDisappear { model.stop() }
    }

    @ViewBuilder
    private var content: some View {
        if model.showsLoading {
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.screenBackground)
        } else {
            transactionList
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if let error = model.state.error {
            ContentUnavailableView {
                Label("Couldn't load transactions", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error)
            }
        } else {
            ContentUnavailableView(
                "No transactions",
                systemImage: "list.bullet.rectangle.portrait",
                description: Text("Transactions for this account will appear here.")
            )
        }
    }

    private var transactionList: some View {
        List {
            if model.state.items.isEmpty {
                Section {
                    emptyState
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            ForEach(model.sections) { section in
                Section(section.label) {
                    ForEach(section.transactions, id: \.id) { transaction in
                        Button {
                            shell.showTransactionDetail(transaction, isInGroup: false)
                        } label: {
                            AccountTransactionRow(transaction: transaction)
                        }
                        .task { await model.loadMoreIfNeeded(appearing: transaction) }
                    }
                }
            }
            if model.state.isLoadingMore {
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .accessibilityLabel("Loading more transactions")
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await model.refresh() }
    }
}
