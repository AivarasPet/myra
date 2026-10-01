import SwiftUI

struct SettingsAccountHeader: View {
    let displayName: String
    let email: String?
    let initials: String?
    let imageURL: URL?
    @ScaledMetric(relativeTo: .title) private var avatarSize: CGFloat = 56

    var body: some View {
        Section {
            HStack(spacing: 16) {
                avatar
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    if let email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.vertical, 6)
            .accessibilityElement(children: .combine)
        }
    }

    private var avatar: some View {
        ZStack {
            Circle().fill(Color.accentColor.opacity(0.18))
            if let imageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    fallbackGlyph
                }
                .clipShape(Circle())
            } else {
                fallbackGlyph
            }
        }
        .frame(width: avatarSize, height: avatarSize)
        .accessibilityHidden(true)
    }

    private var fallbackGlyph: some View {
        Group {
            if let initials {
                Text(initials)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
            } else {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
}
