import SvertoCore
import SwiftUI

struct BankPickerSheet: View {
    let banks: [Aspsp]
    let selected: String?
    let onSelect: (Aspsp) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var results: [Aspsp] {
        guard !trimmedQuery.isEmpty else { return banks }
        return banks.filter { $0.name.range(of: trimmedQuery, options: .caseInsensitive) != nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if results.isEmpty {
                    ContentUnavailableView(
                        trimmedQuery.isEmpty ? "No banks available" : "No matches for \"\(trimmedQuery)\"",
                        systemImage: trimmedQuery.isEmpty ? ConnectorCatalog.bankSystemImage : "magnifyingglass"
                    )
                } else {
                    List(results, id: \.name) { bank in
                        Button {
                            onSelect(bank)
                            dismiss()
                        } label: {
                            HStack {
                                Text(bank.name)
                                Spacer(minLength: 0)
                                if bank.name == selected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                        .accessibilityLabel("Selected")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                        .accessibilityAddTraits(bank.name == selected ? .isSelected : [])
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Your bank")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search banks…")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
