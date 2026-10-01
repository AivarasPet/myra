import SvertoCore
import SwiftUI

struct CategoryTypeRow: View {
    let type: ManagedCategoryType
    let onEdit: (ManagedCategoryType) -> Void
    let onDelete: (ManagedCategoryType) -> Void

    var body: some View {
        if type.isGlobal {
            content
        } else {
            Button {
                onEdit(type)
            } label: {
                content
            }
            .foregroundStyle(.primary)
            .accessibilityHint("Opens the type editor")
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button("Delete", systemImage: "trash", role: .destructive) { onDelete(type) }
                Button("Edit", systemImage: "pencil") { onEdit(type) }
                    .tint(.brand)
            }
            .contextMenu {
                Button("Edit", systemImage: "pencil") { onEdit(type) }
                Button("Delete", systemImage: "trash", role: .destructive) { onDelete(type) }
            }
        }
    }

    private var content: some View {
        HStack(spacing: Layout.rowSpacing) {
            Text(type.name)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            if type.isGlobal {
                ReadOnlyBadge(text: "Global")
            }
        }
        .accessibilityElement(children: .combine)
    }
}
