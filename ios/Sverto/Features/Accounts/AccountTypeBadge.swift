import SwiftUI

struct AccountTypeBadge: View {
    let typeId: Int32
    var size: CGFloat = 44

    private var tint: Color { AccountTypeVisuals.tint(typeId) }

    var body: some View {
        Image(systemName: AccountTypeVisuals.systemImage(typeId))
            .font(.system(size: size * 0.45, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.16), in: .circle)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(AccountType.displayOrder, id: \.self) { type in
            AccountTypeBadge(typeId: type.rawValue, size: 36)
        }
    }
    .padding()
}
