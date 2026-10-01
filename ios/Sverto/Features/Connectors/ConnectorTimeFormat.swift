import Foundation

enum ConnectorTimeFormat {
    static func relative(_ epochSeconds: Int64) -> String {
        RelativeTime.string(epochSeconds: epochSeconds)
    }

    static func absoluteDate(_ epochSeconds: Int64) -> String {
        DateText.mediumDate(epochSeconds: epochSeconds)
    }
}
