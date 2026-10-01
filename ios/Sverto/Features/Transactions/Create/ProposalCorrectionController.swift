import Foundation
import Observation
import SvertoCore

@Observable
final class ProposalCorrectionController {
    private(set) var state: CorrectionState = .idle
    private(set) var typeChange: CorrectionTypeChange?

    private let store: AppStore
    private var resetTask: Task<Void, Never>?

    init(store: AppStore) {
        self.store = store
    }

    func send<Form>(
        _ message: String,
        uploadId: String,
        expecting expectedType: ProposalType,
        map: (_ proposalData: String, _ lookupTables: String) -> Form?
    ) async -> Form? {
        resetTask?.cancel()
        state = .sending
        do {
            let detail = try await store.sendQuickUploadCorrection(uploadId: uploadId, message: message)
            if let returnedType = detail.proposalType.flatMap(ProposalType.init(rawValue:)), returnedType != expectedType {
                state = .idle
                typeChange = CorrectionTypeChange(quickUploadId: uploadId, newProposalType: returnedType)
                return nil
            }
            guard let corrected = map(detail.proposalData ?? "{}", detail.lookupTables) else {
                state = .idle
                return nil
            }
            state = .updated
            resetTask = Task {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { return }
                state = .idle
            }
            return corrected
        } catch {
            state = .idle
            return nil
        }
    }

    func consumeTypeChange() {
        typeChange = nil
    }
}
