import Foundation

nonisolated enum JsonPrettyPrinter {
    static func format(_ json: String) -> String {
        let decoded = (try? JSONDecoder().decode(String.self, from: Data(json.utf8))) ?? json
        guard let object = try? JSONSerialization.jsonObject(with: Data(decoded.utf8)),
              object is [String: Any] || object is [Any] else { return json }
        var characters: [Character] = []
        var inString = false
        var escaped = false
        for character in decoded {
            if inString || !character.isWhitespace {
                characters.append(character)
            }
            if escaped {
                escaped = false
            } else if inString, character == "\\" {
                escaped = true
            } else if character == "\"" {
                inString.toggle()
            }
        }
        var output = ""
        var indent = 0
        inString = false
        escaped = false
        func newline() {
            output.append("\n")
            output.append(String(repeating: "  ", count: max(indent, 0)))
        }
        for (index, character) in characters.enumerated() {
            if inString {
                output.append(character)
                if escaped {
                    escaped = false
                } else if character == "\\" {
                    escaped = true
                } else if character == "\"" {
                    inString = false
                }
                continue
            }
            switch character {
            case "\"":
                inString = true
                output.append(character)
            case "{", "[":
                output.append(character)
                indent += 1
                if index + 1 < characters.count, characters[index + 1] != "}", characters[index + 1] != "]" {
                    newline()
                }
            case "}", "]":
                indent -= 1
                if index > 0, characters[index - 1] != "{", characters[index - 1] != "[" {
                    newline()
                }
                output.append(character)
            case ",":
                output.append(character)
                newline()
            case ":":
                output.append(": ")
            default:
                output.append(character)
            }
        }
        return output
    }
}
