import SwiftUI

struct NewTransactionMenu: View {
    let onAddReceiptPhoto: () -> Void
    let onManualEntry: () -> Void
    let onNewGroup: () -> Void

    var body: some View {
        Menu {
            Button("Add receipt photo", systemImage: "photo.badge.plus", action: onAddReceiptPhoto)
            Button("Manual entry", systemImage: "square.and.pencil", action: onManualEntry)
            Button("New group", systemImage: "square.3.layers.3d", action: onNewGroup)
        } label: {
            Image(systemName: "plus")
        }
        .tint(.primary)
        .accessibilityLabel("Add transaction")
    }
}
