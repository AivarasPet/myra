import SvertoCore
import SwiftUI

struct AssetSearchScene: View {
    let title: String
    let state: AssetSearchState
    let onQueryChange: (String) -> Void
    let onRetry: () -> Void
    let onSelect: (AssetItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var isSearchPresented = true

    private var searchFailure: String? {
        if case let .failed(message) = state { message } else { nil }
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $query, isPresented: $isSearchPresented, prompt: "Search assets…")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .tint(.primary)
                    }
                }
                .onChange(of: query, initial: true) { _, newQuery in onQueryChange(newQuery) }
                .onChange(of: searchFailure) { _, message in
                    if let message { AccessibilityNotification.Announcement(message).post() }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if query.isBlank {
            ContentUnavailableView(
                "Find an asset",
                systemImage: "chart.line.uptrend.xyaxis",
                description: Text("Search for a stock, ETF, currency, or fund")
            )
        } else {
            switch state {
            case .idle, .loading:
                ProgressView("Searching assets…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .failed(message):
                ContentUnavailableView {
                    Label("Couldn’t search assets", systemImage: "exclamationmark.magnifyingglass")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry", action: onRetry)
                }
            case let .results(results):
                if results.isEmpty {
                    ContentUnavailableView("No matches", systemImage: "magnifyingglass", description: Text("Nothing found for \"\(query)\""))
                } else {
                    List(results, id: \.id) { asset in
                        Button {
                            onSelect(asset)
                            dismiss()
                        } label: {
                            CurrencyRow(asset: asset, isSelected: false)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
    }
}
