import Foundation

struct RateLimitInfo: Equatable {
    let message: String
    let retryAfterSeconds: Int64?

    var retryPhrase: String? {
        guard let seconds = retryAfterSeconds, seconds > 0 else { return nil }
        if seconds < 60 {
            return "Try again in a few seconds."
        }
        if seconds < 3600 {
            let minutes = seconds / 60
            return "Try again in about \(minutes) minute\(minutes == 1 ? "" : "s")."
        }
        let hours = seconds / 3600
        return "Try again in about \(hours) hour\(hours == 1 ? "" : "s")."
    }
}
