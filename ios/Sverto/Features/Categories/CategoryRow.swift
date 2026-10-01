import SvertoCore
import SwiftUI

struct CategoryRow: View {
    let category: ManagedCategory
    let onEdit: (ManagedCategory) -> Void
    let onDelete: (ManagedCategory) -> Void

    private var isReadOnly: Bool { category.isGlobal || category.isSystem }

    var body: some View {
        if isReadOnly {
            content
        } else {
            Button {
                onEdit(category)
            } label: {
                content
            }
            .foregroundStyle(.primary)
            .accessibilityHint("Opens the category editor")
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button("Delete", systemImage: "trash", role: .destructive) { onDelete(category) }
                Button("Edit", systemImage: "pencil") { onEdit(category) }
                    .tint(.brand)
            }
            .contextMenu {
                Button("Edit", systemImage: "pencil") { onEdit(category) }
                Button("Delete", systemImage: "trash", role: .destructive) { onDelete(category) }
            }
        }
    }

    private var content: some View {
        HStack(spacing: Layout.rowSpacing) {
            CategoryIconTile(icon: category.icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .fixedSize(horizontal: false, vertical: true)
                Text(category.typeName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if isReadOnly {
                ReadOnlyBadge(text: category.isSystem ? "System" : "Global")
            }
        }
        .accessibilityElement(children: .combine)
    }
}
