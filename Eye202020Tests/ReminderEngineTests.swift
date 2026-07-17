import Foundation
import XCTest
@testable import Eye202020

final class ReminderEngineTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_700_000_000)

    func testDefaultsImplementTwentyTwentyTwentyRule() {
        let settings = ReminderSettings.default

        XCTAssertEqual(settings.workMinutes, 20)
        XCTAssertEqual(settings.lookDistanceFeet, 20)
        XCTAssertEqual(settings.restSeconds, 20)
        XCTAssertEqual(settings.lookDistanceMeters, 6.096, accuracy: 0.001)
    }

    func testFocusDeadlineStartsRestAndReportsFocusedSeconds() {
        var engine = ReminderEngine(settings: .default, now: start)

        XCTAssertEqual(engine.remainingSeconds(at: start), 1_200)
        XCTAssertEqual(
            engine.tick(at: start.addingTimeInterval(1_200)),
            .restBegan(focusSeconds: 1_200)
        )
        XCTAssertTrue(engine.phase.isResting)
        XCTAssertEqual(engine.remainingSeconds(at: start.addingTimeInterval(1_200)), 20)
    }

    func testCompletedRestBeginsFreshFocusCycle() {
        var engine = ReminderEngine(settings: .default, now: start)
        _ = engine.startRestNow(at: start.addingTimeInterval(300))

        XCTAssertEqual(
            engine.tick(at: start.addingTimeInterval(320)),
            .restCompleted
        )
        XCTAssertEqual(engine.remainingSeconds(at: start.addingTimeInterval(320)), 1_200)
    }

    func testSnoozeWaitsFiveMinutesThenRestartsFullRestDuration() {
        var engine = ReminderEngine(settings: .default, now: start)
        _ = engine.startRestNow(at: start)
        engine.snooze(at: start)

        XCTAssertNil(engine.tick(at: start.addingTimeInterval(299)))
        XCTAssertEqual(engine.tick(at: start.addingTimeInterval(300)), .restResumed)
        XCTAssertEqual(engine.remainingSeconds(at: start.addingTimeInterval(300)), 20)
    }

    func testWakeResetAlwaysStartsAFullWorkInterval() {
        var engine = ReminderEngine(settings: .default, now: start)
        _ = engine.startRestNow(at: start.addingTimeInterval(600))

        engine.resetAfterInactivity(at: start.addingTimeInterval(900))

        XCTAssertEqual(engine.remainingSeconds(at: start.addingTimeInterval(900)), 1_200)
        if case .focusing = engine.phase {
            // Expected.
        } else {
            XCTFail("Expected a focus phase after wake")
        }
    }

    func testExpiredPersistedStateIsNotRestored() {
        let expired = ActiveReminderState(
            phase: .resting(deadline: start.addingTimeInterval(-1)),
            focusStartedAt: nil
        )

        let engine = ReminderEngine(settings: .default, now: start, restoredState: expired)

        XCTAssertEqual(engine.remainingSeconds(at: start), 1_200)
    }

    func testSettingsAreClampedToSupportedRanges() {
        var settings = ReminderSettings(
            workMinutes: 0,
            lookDistanceFeet: 1_000,
            restSeconds: 2,
            notificationSoundEnabled: true,
            launchAtLogin: false
        )

        settings.clampToSupportedRanges()

        XCTAssertEqual(settings.workMinutes, 1)
        XCTAssertEqual(settings.lookDistanceFeet, 100)
        XCTAssertEqual(settings.restSeconds, 5)
    }
}
