import Foundation
import Observation
import SvertoCore

struct DownloadedExport: Identifiable, Equatable {
    let id: String
    let url: URL
}

@Observable
final class ExportsViewModel {
    private(set) var exports: [LedgerExport] = []
    private(set) var isLoading = false
    private(set) var isCreating = false
    private(set) var downloadingId: String?
    private(set) var errorMessage: String?
    var downloadedExport: DownloadedExport?

    private let store: AppStore

    init(store: AppStore) {
        self.store = store
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            exports = try await store.listExports()
        } catch {
            errorMessage = error.friendlyMessage
        }
    }

    func createExport(_ format: ExportFormat) async {
        isCreating = true
        errorMessage = nil
        defer { isCreating = false }
        do {
            _ = try await store.createExport(format: format)
            exports = try await store.listExports()
        } catch {
            errorMessage = error.friendlyMessage
        }
    }

    func download(_ export: LedgerExport) async {
        guard downloadingId == nil else { return }
        downloadingId = export.id
        errorMessage = nil
        defer { downloadingId = nil }
        do {
            let remote = try await store.getExportDownloadUrl(fileId: export.id)
            guard let remoteURL = URL(string: remote) else { throw URLError(.badURL) }
            let file = try await ExportDownloader.download(remoteURL, fileName: export.fileName)
            downloadedExport = DownloadedExport(id: export.id, url: file)
        } catch {
            errorMessage = error.friendlyMessage
        }
    }
}

extension ExportFormat {
    var label: String {
        switch self {
        case .csv: "CSV"
        case .beancount: "Beancount"
        }
    }

    var fileExtension: String {
        switch self {
        case .csv: "csv"
        case .beancount: "beancount"
        }
    }
}

extension LedgerExport {
    var fileName: String { "ledger-export-\(id).\(format.fileExtension)" }

    var createdDate: Date? { DateText.parseServerTimestamp(createdAt) }
}
