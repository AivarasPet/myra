import SwiftUI
import SvertoCore

struct CurrencyPickerSheet: View {
    let title: String
    let selectedId: Int32?
    let onSelect: (AssetItem) -> Void

    @Environment(AppServices.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var currencies: [AssetItem] = []
    @State private var isLoading = true

    init(title: String, selectedId: Int32?, onSelect: @escaping (AssetItem) -> Void) {
        self.title = title
        self.selectedId = selectedId
        self.onSelect = onSelect
    }

    private var results: [AssetItem] {
        CurrencySearch.filter(currencies, query: query)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $query, prompt: "Search currencies…")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
        .task { await load() }
    }

    @ViewBuilder
    private var content: some View {
        if isLoading && results.isEmpty {
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if results.isEmpty {
            ContentUnavailableView(CurrencySearch.emptyMessage(for: query), systemImage: CurrencySearch.emptySymbol(for: query))
        } else {
            List(results, id: \.id) { asset in
                Button {
                    onSelect(asset)
                    dismiss()
                } label: {
                    CurrencyRow(asset: asset, isSelected: asset.id == selectedId)
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private func load() async {
        let loaded = (try? await services.store.getAllCurrencies()) ?? []
        currencies = CurrencyOrdering.order(loaded)
        isLoading = false
    }
}

struct CurrencyRow: View {
    let asset: AssetItem
    let isSelected: Bool

    var body: some View {
        AssetListRow(ticker: asset.ticker, name: asset.name, supportingText: asset.name, selected: isSelected)
    }
}

enum CurrencySearch {
    static func filter(_ items: [AssetItem], query: String) -> [AssetItem] {
        guard !isBlank(query) else { return items }
        return items.filter {
            $0.ticker.range(of: query, options: .caseInsensitive) != nil
                || $0.name.range(of: query, options: .caseInsensitive) != nil
        }
    }

    static func emptyMessage(for query: String) -> String {
        isBlank(query) ? "No currencies available" : "No matches for \"\(query)\""
    }

    static func emptySymbol(for query: String) -> String {
        isBlank(query) ? "coloncurrencysign.circle" : "magnifyingglass"
    }

    private static func isBlank(_ query: String) -> Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
