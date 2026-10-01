import Foundation
import Observation
import UniformTypeIdentifiers

@Observable
final class ShareImportModel {
    enum Phase: Equatable {
        case importing
        case finished(added: Int, skipped: Int)
    }

    private(set) var phase: Phase = .importing

    func run(_ items: [NSExtensionItem]) async {
        let providers = items
            .flatMap { $0.attachments ?? [] }
            .filter { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }
        var added = 0
        for provider in providers {
            if await importImage(from: provider) {
                added += 1
            }
        }
        phase = .finished(added: added, skipped: providers.count - added)
    }

    private func importImage(from provider: NSItemProvider) async -> Bool {
        guard let raw = await SharedImageLoader.load(provider), raw.count <= SharedImageDropbox.maxImageBytes else { return false }
        let jpeg = await Task.detached { SharedImageEncoder.jpeg(from: raw) }.value
        guard let jpeg else { return false }
        return SharedImageDropbox.store(jpeg)
    }
}
