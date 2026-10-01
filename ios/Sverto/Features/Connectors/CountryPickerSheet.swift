import SwiftUI

enum CountryNames {
    nonisolated static func localized(_ code: String) -> String? {
        Locale.current.localizedString(forRegionCode: code)
    }

    nonisolated static func display(_ code: String) -> String {
        localized(code).map { "\(code) · \($0)" } ?? code
    }
}

struct CountryPickerSheet: View {
    let countries: [String]
    let selected: String?
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var results: [String] {
        guard !trimmedQuery.isEmpty else { return countries }
        return countries.filter { code in
            code.range(of: trimmedQuery, options: .caseInsensitive) != nil
                || CountryNames.localized(code)?.range(of: trimmedQuery, options: .caseInsensitive) != nil
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if results.isEmpty {
                    ContentUnavailableView(
                        trimmedQuery.isEmpty ? "No countries available" : "No matches for \"\(trimmedQuery)\"",
                        systemImage: trimmedQuery.isEmpty ? "globe" : "magnifyingglass"
                    )
                } else {
                    List(results, id: \.self) { code in
                        Button {
                            onSelect(code)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text(code)
                                    .font(.body.weight(.semibold))
                                    .monospaced()
                                if let name = CountryNames.localized(code) {
                                    Text(name)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                                if code == selected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                        .accessibilityLabel("Selected")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                        .accessibilityAddTraits(code == selected ? .isSelected : [])
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Pick your country")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search countries…")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
