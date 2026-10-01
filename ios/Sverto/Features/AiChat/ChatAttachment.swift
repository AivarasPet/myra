import Foundation
import UIKit

struct ChatAttachment: Identifiable, Equatable {
    let id: UUID
    let data: Data
    let mimeType: String
    let fileName: String
    let localURL: URL
    let thumbnail: UIImage?

    static func == (lhs: ChatAttachment, rhs: ChatAttachment) -> Bool {
        lhs.id == rhs.id
    }
}
