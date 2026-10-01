import Foundation

nonisolated enum SharedImageDropbox {
    static let maxImageBytes = 10 * 1024 * 1024

    static func store(_ jpeg: Data) -> Bool {
        guard jpeg.count <= maxImageBytes, let folder = folderURL() else { return false }
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try jpeg.write(to: folder.appendingPathComponent("\(UUID().uuidString).jpg"), options: .atomic)
            return true
        } catch {
            return false
        }
    }

    private static func folderURL() -> URL? {
        guard let groupId = Bundle.main.object(forInfoDictionaryKey: "SvertoAppGroupIdentifier") as? String, !groupId.isEmpty,
              let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) else { return nil }
        return container.appendingPathComponent("shared-images", isDirectory: true)
    }
}
