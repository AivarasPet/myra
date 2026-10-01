import SwiftUI

struct TransactionTypePickerSheet: View {
    private let title: String
    private let subtitle: String
    private let showGroupOption: Bool
    private let selectedTypeKey: String?
    private let onSelectType: (String) -> Void
    private let onSelectGroup: () -> Void

    @Environment(\.dismiss) private var dismiss

    init(
        title: String = "New transaction",
        subtitle: String = "What did you just do?",
        showGroupOption: Bool = true,
        selectedTypeKey: String? = nil,
        onSelectType: @escaping (String) -> Void,
        onSelectGroup: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showGroupOption = showGroupOption
        self.selectedTypeKey = selectedTypeKey
        self.onSelectType = onSelectType
        self.onSelectGroup = onSelectGroup
    }

    var body: some View {
        NavigationStack {
            List {
                if showGroupOption {
                    Section {
                        Button {
                            dismiss()
                            onSelectGroup()
                        } label: {
                            TransactionTypeOptionRow(
                                systemImage: "square.3.layers.3d",
                                label: "Group",
                                description: "Bundle related transactions together",
                                isSelected: false
                            )
                        }
                        .listRowBackground(Color.accentColor.opacity(0.12))
                    }
                }
                ForEach(TransactionTypeCatalog.groups) { group in
                    Section(group.title) {
                        ForEach(group.types) { type in
                            let isSelected = type.key == selectedTypeKey
                            Button {
                                dismiss()
                                onSelectType(type.key)
                            } label: {
                                TransactionTypeOptionRow(
                                    systemImage: type.systemImage,
                                    label: type.label,
                                    description: type.description,
                                    isSelected: isSelected
                                )
                            }
                            .listRowBackground(isSelected ? Color.accentColor.opacity(0.12) : Color.cardFill)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(title)
            .navigationSubtitle(subtitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct TransactionTypeOptionRow: View {
    let systemImage: String
    let label: String
    let description: String
    let isSelected: Bool

    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 40

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            Image(systemName: isSelected ? "checkmark" : systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: iconSize, height: iconSize)
                .background(.tint.opacity(0.14), in: .rect(cornerRadius: iconSize * 0.3))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.body.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.primary)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
