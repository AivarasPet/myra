import Foundation
import ImageIO
import UniformTypeIdentifiers

enum QuickUploadImagePrep {
    nonisolated static let maxImageBytes = 10 * 1024 * 1024
    private nonisolated static let thumbnailWidth: Double = 200
    private nonisolated static let thumbnailQuality: Double = 0.6

    nonisolated static func prepare(imageData: Data, mimeType: String?) -> PreparedQuickUpload? {
        guard !imageData.isEmpty, imageData.count <= maxImageBytes else { return nil }
        guard let thumbnail = thumbnail(from: imageData) else { return nil }
        return PreparedQuickUpload(imageData: imageData, thumbnail: thumbnail, mimeType: imageMimeType(mimeType))
    }

    private nonisolated static func thumbnail(from imageData: Data) -> Data? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let pixelWidth = properties[kCGImagePropertyPixelWidth] as? Double, pixelWidth > 0,
              let pixelHeight = properties[kCGImagePropertyPixelHeight] as? Double, pixelHeight > 0 else { return nil }
        let orientation = properties[kCGImagePropertyOrientation] as? UInt32 ?? 1
        let isRotated = orientation >= 5
        let displayWidth = isRotated ? pixelHeight : pixelWidth
        let displayHeight = isRotated ? pixelWidth : pixelHeight
        let maxPixelSize = Int((thumbnailWidth * max(displayWidth, displayHeight) / displayWidth).rounded(.up))
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return jpegData(image)
    }

    private nonisolated static func jpegData(_ image: CGImage) -> Data? {
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else {
            return nil
        }
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: thumbnailQuality]
        CGImageDestinationAddImage(destination, image, options as CFDictionary)
        guard CGImageDestinationFinalize(destination), output.length > 0 else { return nil }
        return output as Data
    }

    private nonisolated static func imageMimeType(_ resolved: String?) -> String {
        if let resolved, resolved.hasPrefix("image/") {
            return resolved
        }
        return "image/jpeg"
    }
}
