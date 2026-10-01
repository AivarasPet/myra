import SvertoCore
import SwiftUI

struct AccountPickerSheet: View {
    let accounts: [AccountItem]
    let selectedAccountId: String?
    let onSelect: (AccountItem) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if accounts.isEmpty {
                    ContentUnavailableView("No accounts yet", systemImage: "wallet.bifold")
                } else {
                    List {
                        Section {
                            ForEach(accounts, id: \.id) { account in
                                Button {
                                    onSelect(account)
                                    dismiss()
                                } label: {
                                    AccountPickerRow(account: account, isSelected: account.id == selectedAccountId)
                                }
                            }
                        } header: {
                            Text("Pick which account this entry belongs to")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Select account")
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

private struct AccountPickerRow: View {
    let account: AccountItem
    let isSelected: Bool

    private var tint: Color { isSelected ? .brand : .secondary }

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            Image(systemName: "wallet.bifold")
                .font(.body.weight(.medium))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.14), in: .rect(cornerRadius: 11, style: .continuous))
                .accessibilityHidden(true)
            Text(account.name)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
                    .accessibilityLabel("Selected")
            }
        }
        .foregroundStyle(Color.primary)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
