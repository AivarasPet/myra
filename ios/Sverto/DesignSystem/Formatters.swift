import Foundation

enum RelativeTime {
    nonisolated private static let weekInSeconds: TimeInterval = 7 * 24 * 60 * 60

    nonisolated static func string(epochSeconds: Int64, now: Date = Date()) -> String {
        let date = DateText.date(fromUnix: epochSeconds)
        let elapsed = now.timeIntervalSince(date)
        if abs(elapsed) < 60 {
            return "Just now"
        }
        if abs(elapsed) >= weekInSeconds {
            return DateText.mediumDate(epochSeconds: epochSeconds)
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        let relative = formatter.localizedString(for: date, relativeTo: now)
        return relative.prefix(1).uppercased() + relative.dropFirst()
    }
}

enum DateText {
    nonisolated static let androidParityLocale = Locale(identifier: "en_US")

    nonisolated static func date(fromUnix seconds: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(seconds))
    }

    nonisolated static func dayHeader(epochSeconds: Int64, today: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> String {
        let date = date(fromUnix: epochSeconds)
        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        return date.formatted(.dateTime.month(.abbreviated).day().year().locale(androidParityLocale))
    }

    nonisolated static func parseServerTimestamp(_ value: String) -> Date? {
        (try? Date(value, strategy: .iso8601.time(includingFractionalSeconds: true))) ?? (try? Date(value, strategy: .iso8601))
    }

    nonisolated static func mediumDate(epochSeconds: Int64) -> String {
        date(fromUnix: epochSeconds).formatted(.dateTime.month(.abbreviated).day().year().locale(androidParityLocale))
    }

    nonisolated static func chartScrubLabel(epochSeconds: Int64, intraday: Bool) -> String {
        let date = date(fromUnix: epochSeconds)
        if intraday {
            return date.formatted(.dateTime.month(.abbreviated).day().hour().minute().locale(androidParityLocale))
        }
        return date.formatted(.dateTime.month(.abbreviated).day().year().locale(androidParityLocale))
    }
}

enum PercentText {
    nonisolated static func format(_ fraction: Double, signed: Bool = true, fractionDigits: Int = 1) -> String {
        let percent = fraction * 100
        let magnitude = String(format: "%.\(fractionDigits)f", locale: DateText.androidParityLocale, abs(percent))
        if percent < 0 {
            return "-\(magnitude)%"
        }
        return signed ? "+\(magnitude)%" : "\(magnitude)%"
    }
}
