import Foundation
import UserNotifications
import XCTest
@testable import Eye202020

@MainActor
final class AppModelTests: XCTestCase {
    func testTimerTransitionsUpdateStatisticsAndSendOneNotification() {
        let suiteName = "Eye202020Tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let dateProvider = MutableDateProvider(now: start)
        let settingsStore = SettingsStore(defaults: defaults)
        var settings = ReminderSettings.default
        settings.workMinutes = 1
        settings.restSeconds = 5
        settingsStore.save(settings)

        let notifications = StubNotificationService()
        let statistics = StatisticsStore(defaults: defaults)
        let model = AppModel(
            settingsStore: settingsStore,
            activeStateStore: ActiveStateStore(defaults: defaults),
            statisticsStore: statistics,
            notificationService: notifications,
            launchAtLoginService: StubLaunchAtLoginService(),
            dateProvider: dateProvider
        )

        dateProvider.now = start.addingTimeInterval(60)
        model.processTimerTick()

        XCTAssertTrue(model.phase.isResting)
        XCTAssertEqual(model.today.focusSeconds, 60)
        XCTAssertEqual(notifications.sendCount, 1)

        dateProvider.now = start.addingTimeInterval(65)
        model.processTimerTick()

        XCTAssertEqual(model.today.completed, 1)
        if case .focusing = model.phase {
            // Expected.
        } else {
            XCTFail("Expected a fresh focus cycle after completing the rest")
        }
    }

    func testChangingWorkDurationResetsTheCurrentDeadline() {
        let suiteName = "Eye202020Tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let dateProvider = MutableDateProvider(now: start)
        let model = AppModel(
            settingsStore: SettingsStore(defaults: defaults),
            activeStateStore: ActiveStateStore(defaults: defaults),
            statisticsStore: StatisticsStore(defaults: defaults),
            notificationService: StubNotificationService(),
            launchAtLoginService: StubLaunchAtLoginService(),
            dateProvider: dateProvider
        )

        dateProvider.now = start.addingTimeInterval(120)
        model.updateSettings { $0.workMinutes = 30 }

        XCTAssertEqual(model.remainingSeconds, 1_800)
        XCTAssertEqual(model.settings.workMinutes, 30)
    }
}

private final class MutableDateProvider: DateProviding {
    var now: Date
    init(now: Date) { self.now = now }
}

private final class StubNotificationService: ReminderNotificationServing {
    var sendCount = 0

    func requestAuthorization() async {}
    func authorizationStatus() async -> UNAuthorizationStatus { .authorized }
    func sendRestReminder(soundEnabled: Bool) { sendCount += 1 }
}

private final class StubLaunchAtLoginService: LaunchAtLoginServing {
    var isEnabled = false
    func setEnabled(_ enabled: Bool) throws { isEnabled = enabled }
}
