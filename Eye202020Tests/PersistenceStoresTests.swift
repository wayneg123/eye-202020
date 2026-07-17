import Foundation
import XCTest
@testable import Eye202020

final class PersistenceStoresTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "Eye202020Tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testSettingsRoundTrip() {
        let store = SettingsStore(defaults: defaults)
        let expected = ReminderSettings(
            workMinutes: 35,
            lookDistanceFeet: 30,
            restSeconds: 45,
            notificationSoundEnabled: false,
            launchAtLogin: true
        )

        store.save(expected)

        XCTAssertEqual(store.load(), expected)
    }

    func testStatisticsRecordCompletionSkipAndFocus() {
        let calendar = fixedCalendar()
        let store = StatisticsStore(defaults: defaults, calendar: calendar)
        let date = Date(timeIntervalSince1970: 1_700_000_000)

        store.recordFocus(seconds: 1_200, at: date)
        store.recordCompleted(at: date)
        store.recordSkipped(at: date)

        let result = store.statistics(for: date)
        XCTAssertEqual(result.focusSeconds, 1_200)
        XCTAssertEqual(result.completed, 1)
        XCTAssertEqual(result.skipped, 1)
        XCTAssertEqual(result.completionRate, 0.5)
    }

    func testSevenDaySeriesIncludesEmptyDaysInOrder() {
        let calendar = fixedCalendar()
        let store = StatisticsStore(defaults: defaults, calendar: calendar)
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        store.recordCompleted(at: end)

        let series = store.lastSevenDays(endingAt: end)

        XCTAssertEqual(series.count, 7)
        XCTAssertEqual(series.last?.completed, 1)
        XCTAssertEqual(series.dropLast().reduce(0) { $0 + $1.completed }, 0)
    }

    func testStreakCountsConsecutiveDaysEndingToday() {
        let calendar = fixedCalendar()
        let store = StatisticsStore(defaults: defaults, calendar: calendar)
        let today = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000))
        store.recordCompleted(at: today)
        store.recordCompleted(at: calendar.date(byAdding: .day, value: -1, to: today)!)
        store.recordCompleted(at: calendar.date(byAdding: .day, value: -2, to: today)!)

        XCTAssertEqual(store.currentStreak(at: today), 3)
    }

    private func fixedCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
}
