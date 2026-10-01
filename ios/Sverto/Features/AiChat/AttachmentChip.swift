import SwiftUI

struct AttachmentChip: View {
    let attachment: ChatAttachment
    let onRemove: () -> Void

    @ScaledMetric(relativeTo: .caption2) private var removeBadgeSize: CGFloat = 22

    private let hitTargetSize: CGFloat = 44
    private var badgeOverhang: CGFloat { 6 + (hitTargetSize - removeBadgeSize) / 2 }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumbnail
                .frame(width: 64, height: 64)
                .background(Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 14))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(.systemBackground))
                    .frame(width: removeBadgeSize, height: removeBadgeSize)
                    .background(Color(.label), in: .circle)
                    .frame(width: hitTargetSize, height: hitTargetSize)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .offset(x: badgeOverhang, y: -badgeOverhang)
            .accessibilityLabel("Remove \(attachment.fileName)")
        }
        .padding(.top, badgeOverhang)
        .padding(.trailing, badgeOverhang)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let image = attachment.thumbnail {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .accessibilityLabel("Selected image")
        } else {
            Image(systemName: "doc.text")
                .font(.title2)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Selected file \(attachment.fileName)")
        }
    }
}
