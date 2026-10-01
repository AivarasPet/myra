import SvertoCore
import SwiftUI

struct AccountTypePicker: View {
    let types: [AccountTypeItem]
    let isLoading: Bool
    let error: String?
    let selectedTypeId: Int32?
    let onRetry: () -> Void
    let onSelect: (Int32) -> Void

    var body: some View {
        if types.isEmpty, isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 96)
                .accessibilityLabel("Loading account types")
        } else if let error {
            FormErrorRow(message: "Couldn't load account types. \(error)")
            Button("Retry", action: onRetry)
        } else if types.isEmpty {
            Text("No account types available.")
                .foregroundStyle(.secondary)
            Button("Retry", action: onRetry)
        } else {
            Picker("Type", selection: Binding(
                get: { selectedTypeId },
                set: { typeId in
                    if let typeId {
                        onSelect(typeId)
                    }
                }
            )) {
                if selectedTypeId == nil {
                    Text("Choose account type")
                        .tag(Int32?.none)
                        .disabled(true)
                }
                ForEach(types, id: \.id) { type in
                    HStack(spacing: 12) {
                        AccountTypeBadge(typeId: type.id, size: 32)
                        Text(type.name)
                    }
                    .tag(Int32?.some(type.id))
                }
            } currentValueLabel: {
                Text(types.first(where: { $0.id == selectedTypeId })?.name ?? "Choose account type")
            }
            .pickerStyle(.navigationLink)
        }
    }
}
