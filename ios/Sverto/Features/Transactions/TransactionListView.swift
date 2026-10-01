import SwiftUI
import SvertoCore

struct TransactionListView: View {
    let model: TransactionsViewModel
    let quickUploads: QuickUploadViewModel
    let onTransactionTap: (TransactionListItem) -> Void
    let onQuickUploadTap: (QuickUploadUiItem) -> Void

    private static let loadMoreBuffer = 3
    private static let quickUploadsAnchor = "quick_uploads"

    private var loadMoreTriggerIds: Set<String> {
        Set(model.state.items.suffix(Self.loadMoreBuffer).map(\.id))
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if !quickUploads.items.isEmpty {
                    quickUploadsSection
                }
                if model.state.items.isEmpty {
                    emptySection
                } else {
                    TransactionDaySections(
                        groups: TransactionDayGrouping.group(model.state.items),
                        selectedIds: model.selectedIds,
                        onTap: onTransactionTap,
                        onToggleSelect: model.toggleSelection,
                        onRowAppear: loadMoreIfNearEnd
                    )
                }
                if model.state.isLoadingMore {
                    loadingMoreSection
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                async let transactions: Void = model.refresh()
                async let uploads: Void = quickUploads.refresh()
                _ = await (transactions, uploads)
            }
            .onChange(of: quickUploads.items.count) { oldCount, newCount in
                guard newCount > oldCount else { return }
                withAnimation { proxy.scrollTo(Self.quickUploadsAnchor, anchor: .top) }
            }
        }
    }

    private var quickUploadsSection: some View {
        Section {
            QuickUploadsSection(viewModel: quickUploads, onItemTap: onQuickUploadTap)
                .id(Self.quickUploadsAnchor)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }

    private var emptySection: some View {
        Section {
            ContentUnavailableView("No transactions yet", systemImage: "list.bullet.rectangle.portrait")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }

    private var loadingMoreSection: some View {
        Section {
            ProgressView()
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .accessibilityLabel("Loading more transactions")
        }
    }

    private func loadMoreIfNearEnd(_ transaction: TransactionListItem) {
        guard loadMoreTriggerIds.contains(transaction.id) else { return }
        Task { await model.loadMore() }
    }
}
