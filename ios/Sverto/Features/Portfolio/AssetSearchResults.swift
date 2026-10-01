import SwiftUI
import SvertoCore

struct AssetSearchResults: View {
    let model: MarketsListViewModel
    let onSelect: (AssetSummary) -> Void

    var body: some View {
        let state = model.state
        List {
            ForEach(Array(state.items.enumerated()), id: \.element.id) { index, asset in
                Button {
                    onSelect(asset)
                } label: {
                    AssetSearchResultRow(asset: asset)
                }
                .foregroundStyle(.primary)
                .onAppear {
                    if index >= state.items.count - MarketsListViewModel.loadMoreBuffer {
                        model.loadMore()
                    }
                }
            }
            if state.isLoading || state.isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .accessibilityLabel("Searching")
            }
            if !state.isLoading, state.items.isEmpty {
                ContentUnavailableView(state.isQueryBlank ? "No assets" : "No results", systemImage: "magnifyingglass")
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
    }
}
