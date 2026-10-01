import SwiftUI
import SvertoCore

struct TransactionSearchResults: View {
    let model: TransactionSearchViewModel
    let onTap: (TransactionListItem) -> Void

    private static let loadMoreBuffer = 3

    var body: some View {
        Group {
            if model.items.isEmpty {
                if model.isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    emptyState
                }
            } else {
                resultsList
            }
        }
        .background(.screenBackground)
    }

    private var resultsList: some View {
        List {
            TransactionDaySections(
                groups: TransactionDayGrouping.group(model.items),
                onTap: onTap,
                onRowAppear: loadMoreIfNearEnd
            )
            if model.isLoading || model.isLoadingMore {
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private var emptyState: some View {
        if let error = model.error {
            ContentUnavailableView {
                Label {
                    Text("Search failed")
                } icon: {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.red)
                }
            } description: {
                Text(error)
            }
        } else if model.isQueryBlank {
            ContentUnavailableView("Search transactions", systemImage: "magnifyingglass", description: Text("Find by description"))
        } else {
            ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("No transactions match \"\(model.query)\""))
        }
    }

    private func loadMoreIfNearEnd(_ transaction: TransactionListItem) {
        guard let index = model.items.firstIndex(where: { $0.id == transaction.id }) else { return }
        if index >= model.items.count - Self.loadMoreBuffer {
            model.loadMore()
        }
    }
}
