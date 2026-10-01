import Foundation
import Observation
import SwiftUI
import SvertoCore

struct ChartSample {
    let id: Int
    let date: Date
    let value: Double
    let formattedValue: String
    let accessibilityDate: Text
}

final class ChartSeriesCache {
    private var current: ChartSeries?

    func series(points: [ChartPoint], ticker: String) -> ChartSeries {
        if let current, current.ticker == ticker, current.points == points {
            return current
        }
        let series = ChartSeries(points: points, ticker: ticker)
        current = series
        return series
    }
}

final class ChartSeries {
    let points: [ChartPoint]
    let samples: [ChartSample]
    let domain: ChartYDomain
    let ticker: String
    private let chronologicalSamples: [ChartSample]

    init(points: [ChartPoint], ticker: String) {
        self.points = points
        self.ticker = ticker
        samples = points.enumerated().map {
            let date = DateText.date(fromUnix: $0.element.timestamp)
            return ChartSample(
                id: $0.offset,
                date: date,
                value: $0.element.value,
                formattedValue: Money.format($0.element.value, ticker: ticker),
                accessibilityDate: Text(date, format: .dateTime.year().month().day().hour().minute())
            )
        }
        chronologicalSamples = samples.sorted { $0.date < $1.date }
        domain = ChartYDomain(values: points.map(\.value))
    }

    func nearestIndex(to date: Date?) -> Int? {
        guard let date, chronologicalSamples.count >= 2 else { return nil }
        var lower = 0
        var upper = chronologicalSamples.count
        while lower < upper {
            let middle = (lower + upper) / 2
            if chronologicalSamples[middle].date < date {
                lower = middle + 1
            } else {
                upper = middle
            }
        }
        guard lower > 0 else { return chronologicalSamples.first?.id }
        guard lower < chronologicalSamples.count else { return chronologicalSamples.last?.id }
        let previous = chronologicalSamples[lower - 1]
        let next = chronologicalSamples[lower]
        return date.timeIntervalSince(previous.date) <= next.date.timeIntervalSince(date) ? previous.id : next.id
    }
}

@Observable
final class ChartSelection {
    var date: Date?
    var index: Int?

    func clear() {
        date = nil
        index = nil
    }
}
