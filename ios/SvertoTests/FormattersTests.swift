import Foundation
import Testing
@testable import Sverto

private let gmtCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    return calendar
}()

private func utcDate(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0, minute: Int = 0) throws -> Date {
    try #require(gmtCalendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)))
}

private func epoch(_ date: Date) -> Int64 {
    Int64(date.timeIntervalSince1970)
}

struct DayHeaderTests {
    @Test func sameDayIsToday() throws {
        let today = try utcDate(2026, 7, 26, hour: 15)
        let morning = try utcDate(2026, 7, 26, hour: 1)

        #expect(DateText.dayHeader(epochSeconds: epoch(morning), today: today, calendar: gmtCalendar) == "Today")
        #expect(DateText.dayHeader(epochSeconds: epoch(today), today: today, calendar: gmtCalendar) == "Today")
    }

    @Test func previousDayIsYesterday() throws {
        let today = try utcDate(2026, 7, 26, hour: 15)
        let lateYesterday = try utcDate(2026, 7, 25, hour: 23, minute: 59)

        #expect(DateText.dayHeader(epochSeconds: epoch(lateYesterday), today: today, calendar: gmtCalendar) == "Yesterday")
    }

    @Test func olderDatesUseAbbreviatedMonthDayYear() throws {
        let today = try utcDate(2026, 7, 26)

        #expect(DateText.dayHeader(epochSeconds: epoch(try utcDate(2026, 7, 24)), today: today, calendar: gmtCalendar) == "Jul 24, 2026")
        #expect(DateText.dayHeader(epochSeconds: epoch(try utcDate(2026, 7, 19)), today: today, calendar: gmtCalendar) == "Jul 19, 2026")
        #expect(DateText.dayHeader(epochSeconds: epoch(try utcDate(2025, 12, 31)), today: today, calendar: gmtCalendar) == "Dec 31, 2025")
    }

    @Test func futureDatesAreNeverTodayOrYesterday() throws {
        let today = try utcDate(2026, 7, 26)

        #expect(DateText.dayHeader(epochSeconds: epoch(try utcDate(2026, 7, 27)), today: today, calendar: gmtCalendar) == "Jul 27, 2026")
    }

    @Test func yesterdayCrossesMonthAndYearBoundaries() throws {
        #expect(DateText.dayHeader(epochSeconds: epoch(try utcDate(2026, 7, 31)), today: try utcDate(2026, 8, 1), calendar: gmtCalendar) == "Yesterday")
        #expect(DateText.dayHeader(epochSeconds: epoch(try utcDate(2025, 12, 31)), today: try utcDate(2026, 1, 1), calendar: gmtCalendar) == "Yesterday")
    }

    @Test func unixConversionRoundTrips() {
        #expect(DateText.date(fromUnix: 0) == Date(timeIntervalSince1970: 0))
        #expect(DateText.date(fromUnix: 1_753_000_000).timeIntervalSince1970 == 1_753_000_000)
    }
}

struct RelativeTimeTests {
    private let now = Date(timeIntervalSince1970: 1_753_000_000)

    private func relative(secondsAgo: TimeInterval) -> String {
        RelativeTime.string(epochSeconds: Int64(now.timeIntervalSince1970 - secondsAgo), now: now)
    }

    @Test func underAMinuteEitherDirectionIsJustNow() {
        #expect(relative(secondsAgo: 0) == "Just now")
        #expect(relative(secondsAgo: 30) == "Just now")
        #expect(relative(secondsAgo: 59) == "Just now")
        #expect(relative(secondsAgo: -30) == "Just now")
    }

    @Test func aWeekOrOlderFallsBackToAbsoluteDate() {
        let week: TimeInterval = 7 * 24 * 60 * 60
        let exactlyAWeek = Int64(now.timeIntervalSince1970 - week)
        let tenDays = Int64(now.timeIntervalSince1970 - 10 * 24 * 60 * 60)

        #expect(relative(secondsAgo: week) == DateText.mediumDate(epochSeconds: exactlyAWeek))
        #expect(relative(secondsAgo: 10 * 24 * 60 * 60) == DateText.mediumDate(epochSeconds: tenDays))
    }

    @Test func inBetweenIsRelativeAndCapitalised() throws {
        let minute: TimeInterval = 60
        let hour = 60 * minute
        let day = 24 * hour
        let samples = [minute, 5 * minute, 3 * hour, day, 6 * day]
        for secondsAgo in samples {
            let text = relative(secondsAgo: secondsAgo)
            let first = try #require(text.first)

            #expect(text != "Just now")
            #expect(text != DateText.mediumDate(epochSeconds: Int64(now.timeIntervalSince1970 - secondsAgo)))
            #expect(first.isUppercase || first.isNumber)
        }
    }
}

struct PercentTextTests {
    @Test func positiveFractionsAreSignedByDefault() {
        #expect(PercentText.format(0.125) == "+12.5%")
        #expect(PercentText.format(1.5) == "+150.0%")
    }

    @Test func negativeFractionsKeepMinusRegardlessOfSignedFlag() {
        #expect(PercentText.format(-0.05) == "-5.0%")
        #expect(PercentText.format(-0.05, signed: false) == "-5.0%")
    }

    @Test func unsignedDropsThePlus() {
        #expect(PercentText.format(0.125, signed: false) == "12.5%")
    }

    @Test func zeroIsPositive() {
        #expect(PercentText.format(0) == "+0.0%")
        #expect(PercentText.format(0, signed: false) == "0.0%")
        #expect(PercentText.format(-0.0) == "+0.0%")
    }

    @Test func fractionDigitsAreConfigurable() {
        #expect(PercentText.format(0.1234, fractionDigits: 2) == "+12.34%")
        #expect(PercentText.format(0.126, fractionDigits: 0) == "+13%")
        #expect(PercentText.format(-0.001, fractionDigits: 3) == "-0.100%")
    }

    @Test func usesDotDecimalSeparatorIndependentOfDeviceLocale() {
        #expect(PercentText.format(0.5).contains("."))
        #expect(!PercentText.format(0.5).contains(","))
    }
}
