import Foundation
import Observation
import SvertoCore

@Observable
final class MarketsListViewModel {
    static let pageSize: Int32 = 25
    static let loadMoreBuffer = 5
    private static let searchDebounce: Duration = .milliseconds(300)

    private(set) var state = MarketsState()

    private let store: AppStore
    private var searchTask: Task<Void, Never>?

    init(store: AppStore) {
        self.store = store
    }

    func onSearchExpanded() {
        if searchTask == nil {
            search(state.query, debounce: false)
        }
    }

    func onQueryChange(_ query: String) {
        guard query != state.query else { return }
        state.query = query
        search(query, debounce: true)
    }

    func loadMore() {
        let snapshot = state
        guard !snapshot.isLoadingMore, snapshot.hasMore, !snapshot.isLoading else { return }
        state.isLoadingMore = true
        Task {
            defer { state.isLoadingMore = false }
            do {
                let page = try await store.searchGlobalAssets(query: snapshot.query, start: Int32(snapshot.items.count), count: Self.pageSize)
                guard state.query == snapshot.query else { return }
                state.items += page.items
                state.total = Int(page.total)
            } catch {}
        }
    }

    private func search(_ query: String, debounce: Bool) {
        searchTask?.cancel()
        if !debounce {
            state.isLoading = true
        }
        searchTask = Task {
            if debounce {
                do {
                    try await Task.sleep(for: Self.searchDebounce)
                } catch {
                    return
                }
                state.isLoading = true
            }
            do {
                let page = try await store.searchGlobalAssets(query: query, start: 0, count: Self.pageSize)
                guard !Task.isCancelled else { return }
                state.items = page.items
                state.total = Int(page.total)
            } catch {
                guard !Task.isCancelled else { return }
            }
            state.isLoading = false
        }
    }
}
