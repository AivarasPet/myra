import Foundation
import FoundationModels
import SvertoCore

enum CategorySuggester {
    private static let inferenceTimeout: Duration = .seconds(10)

    static var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability { return true }
        return false
    }

    static func prefetch() {
        guard isAvailable else { return }
        LanguageModelSession().prewarm()
    }

    static func suggest(description: String, categories: [CategoryItem]) async -> CategoryItem? {
        guard isAvailable else { return nil }
        let prompt = CategoryPrompt.build(description: description, categories: categories)
        do {
            let reply = try await respondWithTimeout(to: prompt)
            return CategoryPrompt.parse(reply, categories: categories)
        } catch {
            return nil
        }
    }

    private static func respondWithTimeout(to prompt: String) async throws -> String {
        try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                try await LanguageModelSession().respond(to: prompt).content
            }
            group.addTask {
                try await Task.sleep(for: inferenceTimeout)
                throw CancellationError()
            }
            guard let reply = try await group.next() else { throw CancellationError() }
            group.cancelAll()
            return reply
        }
    }
}
