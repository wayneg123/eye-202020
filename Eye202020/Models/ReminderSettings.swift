import Foundation

struct ReminderSettings: Codable, Equatable {
    static let defaultsKey = "reminder.settings.v1"

    var workMinutes: Int
    var lookDistanceFeet: Int
    var restSeconds: Int
    var notificationSoundEnabled: Bool
    var launchAtLogin: Bool

    static let `default` = ReminderSettings(
        workMinutes: 20,
        lookDistanceFeet: 20,
        restSeconds: 20,
        notificationSoundEnabled: true,
        launchAtLogin: false
    )

    mutating func clampToSupportedRanges() {
        workMinutes = min(max(workMinutes, 1), 120)
        lookDistanceFeet = min(max(lookDistanceFeet, 5), 100)
        restSeconds = min(max(restSeconds, 5), 120)
    }

    var lookDistanceMeters: Double {
        Double(lookDistanceFeet) * 0.3048
    }
}
