import Foundation
import PhotosUI
import SwiftUI

enum ReceiptPhotoImport {
    static let failureMessage = "Couldn't add that image"

    static func prepare(_ item: PhotosPickerItem) async -> PreparedQuickUpload? {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return nil }
        let mimeType = item.supportedContentTypes.first { $0.conforms(to: .image) }?.preferredMIMEType
        return await prepare(imageData: data, mimeType: mimeType)
    }

    static func prepare(imageData: Data, mimeType: String?) async -> PreparedQuickUpload? {
        await Task.detached {
            QuickUploadImagePrep.prepare(imageData: imageData, mimeType: mimeType)
        }.value
    }
}
