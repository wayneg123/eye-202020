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
        guard soundEnabled else { return }
        // The nonactivating panel provides the visual reminder; avoid a second banner.
        let content = UNMutableNotificationContent()
        content.sound = .default

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
        [.sound]
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
