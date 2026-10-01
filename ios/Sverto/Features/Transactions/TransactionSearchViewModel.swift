import Foundation
import Observation
import SvertoCore

@Observable
final class TransactionSearchViewModel {
    private(set) var query = ""
    private(set) var items: [TransactionListItem] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasMore = false
    private(set) var error: String?

    private let store: AppStore
    private var searchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var nextCursor: String?

    private static let debounce: Duration = .milliseconds(300)

    init(store: AppStore) {
        self.store = store
    }

    var isQueryBlank: Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func onQueryChange(_ newQuery: String) {
        guard newQuery != query else { return }
        searchTask?.cancel()
        loadMoreTask?.cancel()
        nextCursor = nil
        query = newQuery
        items = []
        hasMore = false
        isLoadingMore = false
        error = nil

        guard !isQueryBlank else {
            isLoading = false
            return
        }
        isLoading = true
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(for: Self.debounce)
                let page = try await store.searchTransactions(query: newQuery, cursor: nil)
                guard query == newQuery else { return }
                nextCursor = page.nextCursor
                items = page.items
                hasMore = page.hasMore
                isLoading = false
                error = nil
            } catch is CancellationError {
                return
            } catch {
                guard query == newQuery else { return }
                isLoading = false
                self.error = error.friendlyMessage
            }
        }
    }

    func loadMore() {
        guard let cursor = nextCursor, hasMore, !isLoading, !isLoadingMore, !isQueryBlank else { return }
        let currentQuery = query
        isLoadingMore = true
        loadMoreTask = Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await store.searchTransactions(query: currentQuery, cursor: cursor)
                guard query == currentQuery else { return }
                nextCursor = page.nextCursor
                items += page.items
                hasMore = page.hasMore
                isLoadingMore = false
            } catch is CancellationError {
                return
            } catch {
                guard query == currentQuery else { return }
                isLoadingMore = false
                self.error = error.friendlyMessage
            }
        }
    }
}
