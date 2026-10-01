import Foundation

struct ToolParamRow: Identifiable {
    let key: String
    let value: String

    var id: String { key }
}

nonisolated enum ToolParamRows {
    static func parse(_ params: String) -> [ToolParamRow]? {
        guard let data = params.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              !object.isEmpty else { return nil }
        return object.keys.sorted().map { ToolParamRow(key: $0, value: display(object[$0])) }
    }

    private static func display(_ value: Any?) -> String {
        switch value {
        case nil, is NSNull:
            return "null"
        case let string as String:
            return string
        case let number as NSNumber:
            return CFGetTypeID(number) == CFBooleanGetTypeID() ? (number.boolValue ? "true" : "false") : number.stringValue
        case let container as [String: Any]:
            return serialized(container)
        case let container as [Any]:
            return serialized(container)
        default:
            return String(describing: value ?? "")
        }
    }

    private static func serialized(_ object: Any) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]),
              let text = String(data: data, encoding: .utf8) else { return String(describing: object) }
        return text
    }
}
