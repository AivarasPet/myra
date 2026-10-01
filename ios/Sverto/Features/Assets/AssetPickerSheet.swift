import SvertoCore
import SwiftUI

struct AssetPickerSheet: View {
    let title: String
    let onSelect: (AssetItem) -> Void

    @Environment(AppServices.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [AssetItem] = []
    @State private var isLoading = false
    @FocusState private var isSearchFocused: Bool

    init(title: String, onSelect: @escaping (AssetItem) -> Void) {
        self.title = title
        self.onSelect = onSelect
    }

    private var isQueryBlank: Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $query, prompt: "Search assets…")
                .searchFocused($isSearchFocused)
                .autocorrectionDisabled()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
        .task(id: query) { await search() }
        .task {
            try? await Task.sleep(for: .milliseconds(150))
            isSearchFocused = true
        }
    }

    @ViewBuilder
    private var content: some View {
        if isQueryBlank {
            ContentUnavailableView("Search for an asset", systemImage: "magnifyingglass")
        } else if isLoading && results.isEmpty {
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if results.isEmpty {
            ContentUnavailableView("No results", systemImage: "magnifyingglass")
        } else {
            List(results, id: \.id) { asset in
                Button {
                    onSelect(asset)
                    dismiss()
                } label: {
                    AssetListRow(ticker: asset.ticker, name: asset.name, supportingText: asset.name)
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private func search() async {
        guard !isQueryBlank else {
            results = []
            isLoading = false
            return
        }
        isLoading = true
        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled else { return }
        let found = (try? await services.store.searchAssets(query: query)) ?? []
        guard !Task.isCancelled else { return }
        results = found
        isLoading = false
    }
}
