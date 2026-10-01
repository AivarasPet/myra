import Foundation
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

nonisolated enum ChatAttachmentLoader {
    private static let thumbnailSize = CGSize(width: 128, height: 128)
    private static let fallbackImageMimeType = "image/jpeg"

    static func load(photoItems: [PhotosPickerItem]) async -> [ChatAttachment] {
        var result: [ChatAttachment] = []
        for item in photoItems {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            let type = item.supportedContentTypes.first { $0.conforms(to: .image) } ?? .jpeg
            let fileName = "image.\(type.preferredFilenameExtension ?? "jpg")"
            if let attachment = await make(data: data, mimeType: type.preferredMIMEType ?? fallbackImageMimeType, fileName: fileName) {
                result.append(attachment)
            }
        }
        return result
    }

    @concurrent
    static func load(fileURLs: [URL]) async -> [ChatAttachment] {
        var result: [ChatAttachment] = []
        for url in fileURLs {
            let isScoped = url.startAccessingSecurityScopedResource()
            defer {
                if isScoped { url.stopAccessingSecurityScopedResource() }
            }
            guard let data = try? Data(contentsOf: url) else { continue }
            let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
            if let attachment = await make(data: data, mimeType: mimeType, fileName: url.lastPathComponent) {
                result.append(attachment)
            }
        }
        return result
    }

    @concurrent
    static func load(cameraImage: UIImage) async -> ChatAttachment? {
        guard let data = cameraImage.jpegData(compressionQuality: 0.9) else { return nil }
        return await make(data: data, mimeType: fallbackImageMimeType, fileName: "camera_\(UUID().uuidString).jpg")
    }

    @concurrent
    private static func make(data: Data, mimeType: String, fileName: String) async -> ChatAttachment? {
        let id = UUID()
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("chat-attachments", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let localURL = directory.appendingPathComponent("\(id.uuidString)-\(fileName)")
        guard (try? data.write(to: localURL)) != nil else { return nil }
        let thumbnail = mimeType.hasPrefix("image/") ? await UIImage(data: data)?.byPreparingThumbnail(ofSize: thumbnailSize) : nil
        return ChatAttachment(id: id, data: data, mimeType: mimeType, fileName: fileName, localURL: localURL, thumbnail: thumbnail)
    }
}
