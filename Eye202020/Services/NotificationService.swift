import Foundation
import UserNotifications

protocol ReminderNotificationServing {
    func requestAuthorization() async
    func authorizationStatus() async -> UNAuthorizationStatus
    func sendRestReminder(soundEnabled: Bool)
}

final class NotificationService: NSObject, ReminderNotificationServing, UNUserNotificationCenterDelegate {
    private let center: UNUserNotificationCenter

    override init() {
        center = .current()
        super.init()
        center.delegate = self
    }

    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func sendRestReminder(soundEnabled: Bool) {
        let content = UNMutableNotificationContent()
        content.title = L10n.text("Time for a break 👀")
        content.body = L10n.text("Look into the distance and relax your eyes to ease fatigue.")
        content.sound = soundEnabled ? .default : nil

        let request = UNNotificationRequest(
            identifier: "eye-rest-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        center.add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run {
            NotificationCenter.default.post(name: .showRestWindow, object: nil)
        }
    }
}
