import SwiftUI
import SvertoCore

struct TransactionDetailHero: View {
    let transaction: TransactionListItem
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 6) {
            TransactionGlyph(transaction: transaction, size: 72)
                .dynamicTypeSize(dynamicTypeSize.isAccessibilitySize ? .large : dynamicTypeSize)
                .padding(.top, 12)
                .padding(.bottom, 8)
            Text(transaction.description)
                .font(.title.weight(.medium))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
            Text(transaction.typeLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(transaction.amountDisplay)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
                .padding(.horizontal, 24)
            if let secondary = transaction.secondaryAmountDisplay {
                Text(signedSecondaryAmount(secondary))
                    .font(.title3)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            if !transaction.accountName.isEmpty || !transaction.categoryName.isEmpty {
                metaRow
                    .padding(.top, 8)
                    .padding(.horizontal, Layout.cardPadding)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var metaRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) { metaChips }
            VStack(spacing: 8) { metaChips }
        }
    }

    @ViewBuilder
    private var metaChips: some View {
        if !transaction.accountName.isEmpty {
            TransactionMetaChip(label: transaction.accountName)
        }
        if let secondary = transaction.secondaryAccountName, !secondary.isEmpty {
            Image(systemName: "arrow.forward")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityLabel("to")
            TransactionMetaChip(label: secondary)
        }
        if !transaction.categoryName.isEmpty {
            TransactionMetaChip(label: transaction.categoryName)
        }
    }
}

struct TransactionMetaChip: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemGroupedBackground), in: .capsule)
    }
}

struct TransactionQuickAction: View {
    let systemImage: String
    let label: String
    var isDestructive = false
    var isPrimary = false
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if isPrimary {
                actionButton
                    .buttonStyle(.borderedProminent)
                    .tint(.brand)
            } else {
                actionButton
                    .buttonStyle(.bordered)
                    .tint(isDestructive ? .red : .brand)
            }
        }
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(label)
    }

    private var actionButton: some View {
        Button(role: isDestructive ? .destructive : nil, action: action) {
            Label(label, systemImage: systemImage)
                .labelStyle(.titleAndIcon)
                .font(dynamicTypeSize.isAccessibilitySize ? .footnote.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(isPrimary ? Color.onAccent : isDestructive ? .red : .primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 24)
        }
    }
}

struct TransactionDetailRow: View {
    let label: String
    let value: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 16))
        layout {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 8)
            }
            Text(value)
                .font(.body)
                .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Layout.cardPadding)
        .accessibilityElement(children: .combine)
    }
}
