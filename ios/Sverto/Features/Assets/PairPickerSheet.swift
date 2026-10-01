import SvertoCore
import SwiftUI

struct PairPickerSheet: View {
    let pairs: [AssetPairRef]
    let selectedPairId: Int32?
    let onSelect: (AssetPairRef) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(pairs, id: \.assetId) { pair in
                let isSelected = pair.assetId == selectedPairId
                Button {
                    onSelect(pair)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pair.ticker)
                                .fontWeight(isSelected ? .semibold : .regular)
                            Text(pair.converted ? "Converted" : pair.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                        if isSelected {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .foregroundStyle(.tint)
                                .accessibilityLabel("Selected")
                        }
                    }
                }
                .foregroundStyle(.primary)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Pair")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
