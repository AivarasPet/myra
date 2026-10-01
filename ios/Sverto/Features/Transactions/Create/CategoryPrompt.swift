import Foundation
import SvertoCore

nonisolated enum CategoryPrompt {
    private static let maxDescriptionChars = 200
    private static let maxNameChars = 100

    static func build(description: String, categories: [CategoryItem]) -> String {
        var lines = ["Classify a personal finance transaction into one of these categories.", "Categories (id: name):"]
        lines += categories.map { "\($0.id): \(sanitize($0.name, maxChars: maxNameChars))" }
        lines.append("")
        lines.append("Transaction description: \"\(sanitize(description, maxChars: maxDescriptionChars))\"")
        lines.append(
            "Reply with only the id number of the best matching category. "
                + "The id must be one of the ids listed above. If no category fits well, reply NONE."
        )
        return lines.joined(separator: "\n")
    }

    static func parse(_ raw: String, categories: [CategoryItem]) -> CategoryItem? {
        let cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.firstMatch(of: /^\W*none\b/.ignoresCase()) != nil { return nil }
        var seen = Set<Int32>()
        let validIds = cleaned.matches(of: /\d+/)
            .compactMap { Int32(String($0.output)) }
            .filter { id in categories.contains { $0.id == id } && seen.insert(id).inserted }
        guard validIds.count == 1, let id = validIds.first else { return nil }
        return categories.first { $0.id == id }
    }

    private static func sanitize(_ text: String, maxChars: Int) -> String {
        String(text.replacing(/\s+/, with: " ").trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxChars))
    }
}
