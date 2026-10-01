import Foundation

nonisolated enum SharedImageInbox {
    static func drain() -> [Data] {
        guard let folder = folderURL(),
              let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        else { return [] }
        return files
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .compactMap { url in
                defer { try? FileManager.default.removeItem(at: url) }
                return try? Data(contentsOf: url)
            }
    }

    private static func folderURL() -> URL? {
        guard let groupId = Bundle.main.object(forInfoDictionaryKey: "SvertoAppGroupIdentifier") as? String, !groupId.isEmpty,
              let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) else { return nil }
        return container.appendingPathComponent("shared-images", isDirectory: true)
    }
}
