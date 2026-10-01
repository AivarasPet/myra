import Foundation
import UIKit
import UniformTypeIdentifiers

nonisolated enum SharedImageLoader {
    static func load(_ provider: NSItemProvider) async -> Data? {
        let contentType = provider.registeredContentTypes.first { $0.conforms(to: .image) } ?? .image
        if let data = await loadData(provider, as: contentType) { return data }
        if let data = await loadFile(provider, as: contentType) { return data }
        return await loadItem(provider)
    }

    private static func loadData(_ provider: NSItemProvider, as contentType: UTType) async -> Data? {
        await withCheckedContinuation { continuation in
            _ = provider.loadDataRepresentation(for: contentType) { data, _ in
                continuation.resume(returning: data)
            }
        }
    }

    private static func loadFile(_ provider: NSItemProvider, as contentType: UTType) async -> Data? {
        await withCheckedContinuation { continuation in
            _ = provider.loadFileRepresentation(for: contentType, openInPlace: false) { url, _, _ in
                continuation.resume(returning: url.flatMap(readFile))
            }
        }
    }

    private static func loadItem(_ provider: NSItemProvider) async -> Data? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.image.identifier) { @Sendable item, _ in
                continuation.resume(returning: imageData(from: item))
            }
        }
    }

    private static func imageData(from item: (any NSSecureCoding)?) -> Data? {
        switch item {
        case let data as Data: data
        case let url as URL: readFile(url)
        case let image as UIImage: image.jpegData(compressionQuality: 0.9)
        default: nil
        }
    }

    private static func readFile(_ url: URL) -> Data? {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer { if isScoped { url.stopAccessingSecurityScopedResource() } }
        return try? Data(contentsOf: url)
    }
}
