import Foundation
import Observation
import SvertoCore

@Observable
final class AccountTransactionsViewModel {
    nonisolated static let loadMoreBuffer = 5

    private(set) var state = AccountTransactionsState(
        isLoading: true,
        isLoadingMore: false,
        error: nil,
        items: [],
        hasMore: false
    )
    private(set) var isRefreshing = false

    private let store: AppStore
    private let accountId: String
    private var bridge: AccountTransactionsObserverBridge?
    private var hasLoaded = false

    init(store: AppStore, accountId: String) {
        self.store = store
        self.accountId = accountId
    }

    var showsLoading: Bool { state.isLoading && !isRefreshing }

    var orderedItems: [TransactionListItem] {
        state.items.sorted { $0.date > $1.date }
    }

    var sections: [TransactionDayGroup] {
        TransactionDayGrouping.group(orderedItems)
    }

    func start() async {
        observeIfNeeded()
        guard !hasLoaded else { return }
        hasLoaded = true
        await store.loadAccountTransactions(accountId: accountId)
    }

    func stop() {
        guard bridge != nil else { return }
        bridge = nil
        store.unobserveAccountTransactions()
    }

    func refresh() async {
        isRefreshing = true
        await store.refreshAccountTransactions()
        isRefreshing = false
    }

    func loadMoreIfNeeded(appearing transaction: TransactionListItem) async {
        let ordered = orderedItems
        guard let index = ordered.firstIndex(where: { $0.id == transaction.id }),
              index >= ordered.count - Self.loadMoreBuffer,
              state.hasMore, !state.isLoadingMore, !state.isLoading else { return }
        await store.loadMoreAccountTransactions()
    }

    private func observeIfNeeded() {
        guard bridge == nil else { return }
        let bridge = AccountTransactionsObserverBridge { [weak self] state in
            Task { @MainActor [weak self] in self?.state = state }
        }
        self.bridge = bridge
        store.observeAccountTransactions(observer: bridge)
    }
}
