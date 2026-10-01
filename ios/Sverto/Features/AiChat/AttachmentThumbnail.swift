import SwiftUI

struct AttachmentThumbnail: View {
    let url: String
    let mediaType: String

    private var isImage: Bool { mediaType.hasPrefix("image/") }

    var body: some View {
        Group {
            if isImage {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case let .success(image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder(systemImage: "photo.badge.exclamationmark", label: "Image unavailable")
                    default:
                        ProgressView()
                    }
                }
                .accessibilityLabel("Attached image")
            } else {
                placeholder(systemImage: "paperclip", label: "Attachment")
                    .accessibilityLabel("Attached file")
            }
        }
        .frame(width: 220, height: 160)
        .background(Color(.tertiarySystemFill))
        .clipShape(.rect(cornerRadius: 20))
    }

    private func placeholder(systemImage: String, label: String) -> some View {
        Label(label, systemImage: systemImage)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)
    }
}
