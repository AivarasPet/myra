import SvertoCore
import SwiftUI

struct CategorySearchScene: View {
    let results: [CategoryItem]
    let isLoading: Bool
    let onQueryChange: (String) -> Void
    let onSelect: (CategoryItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var isSearchPresented = true

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Category")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $query, isPresented: $isSearchPresented, prompt: "Search categories…")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .onChange(of: query) { _, newQuery in onQueryChange(newQuery) }
        }
    }

    @ViewBuilder
    private var content: some View {
        if results.isEmpty, isLoading {
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if results.isEmpty, !query.isBlank {
            ContentUnavailableView("No matches", systemImage: "magnifyingglass", description: Text("Nothing found for \"\(query)\""))
        } else if results.isEmpty {
            ContentUnavailableView("Find a category", systemImage: "tag", description: Text("Search for groceries, travel, salary…"))
        } else {
            List(results, id: \.id) { category in
                Button {
                    onSelect(category)
                    dismiss()
                } label: {
                    HStack(spacing: Layout.rowSpacing) {
                        CategoryIconTile(icon: category.icon)
                        Text(category.name)
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(.primary)
            }
            .listStyle(.insetGrouped)
        }
    }
}
