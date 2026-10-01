import SwiftUI

struct LucideIconPickerSheet: View {
    private let selected: String?
    private let onSelect: (String) -> Void

    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    init(selected: String? = nil, onSelect: @escaping (String) -> Void) {
        self.selected = selected.map(LucideCatalog.normalizedName)
        self.onSelect = onSelect
    }

    private var filtered: [String] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return LucideCatalog.all }
        return LucideCatalog.all.filter { $0.contains(needle) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    iconGrid
                }
            }
            .navigationTitle("Choose an icon")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search icons…")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }

    private var iconGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: 4)], spacing: 4) {
                ForEach(filtered, id: \.self) { name in
                    Button {
                        onSelect(name)
                        dismiss()
                    } label: {
                        LucideIcon(name: name, size: 24, color: .primary)
                            .frame(width: 56, height: 56)
                            .background(
                                name == selected ? Color.brand.opacity(0.14) : .clear,
                                in: .rect(cornerRadius: 12, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(name.replacingOccurrences(of: "-", with: " "))
                    .accessibilityAddTraits(name == selected ? .isSelected : [])
                }
            }
            .padding(12)
        }
    }
}
