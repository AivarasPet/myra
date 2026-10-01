import Foundation
import Testing
@testable import Sverto

struct JsonPrettyPrinterTests {
    @Test func decodesStructuredJsonStringResults() throws {
        let raw = #"{"accounts":[{"name":"Joint Bills","balance":123.45}],"complete":true}"#
        let wrapped = String(decoding: try JSONEncoder().encode(raw), as: UTF8.self)
        let formatted = JsonPrettyPrinter.format(wrapped)
        #expect(formatted.contains("\n  \"accounts\": ["))
        #expect(try JSONSerialization.jsonObject(with: Data(formatted.utf8)) as? NSDictionary == JSONSerialization.jsonObject(with: Data(raw.utf8)) as? NSDictionary)
    }

    @Test func escapedQuotesAndPunctuationStayInsideStrings() {
        let raw = #"{"description":"He said \"yes, {today}\"","path":"C:\\files","value":0.004}"#
        let formatted = JsonPrettyPrinter.format(raw)
        #expect(formatted.contains(#""description": "He said \"yes, {today}\""#))
        #expect(formatted.contains(#""path": "C:\\files""#))
        #expect(formatted.contains(#""value": 0.004"#))
    }

    @Test func formattingPreservesNumericPrecisionAndFieldOrder() {
        let raw = #"{"z":123456789012345678901234567890.123456789,"a":1.234567890123456789e-20}"#
        #expect(JsonPrettyPrinter.format(raw) == "{\n  \"z\": 123456789012345678901234567890.123456789,\n  \"a\": 1.234567890123456789e-20\n}")
    }

    @Test func malformedAndPlainTextRemainUnchanged() {
        for value in ["Server unavailable", #"{"partial": [1,}"#, "42", "null", #""A plain string""#] {
            #expect(JsonPrettyPrinter.format(value) == value)
        }
    }

    @Test func emptyContainersStayCompactAndFormattingIsIdempotent() {
        let raw = #"{"empty":{},"list":[],"values":[true,false,null]}"#
        let formatted = JsonPrettyPrinter.format(raw)
        #expect(formatted.contains("\"empty\": {}"))
        #expect(formatted.contains("\"list\": []"))
        #expect(JsonPrettyPrinter.format(formatted) == formatted)
    }
}
