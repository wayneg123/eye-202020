import Foundation

struct DailyStatistics: Codable, Equatable, Identifiable {
    var dateKey: String
    var completed: Int = 0
    var skipped: Int = 0
    var focusSeconds: Int = 0

    var id: String { dateKey }

    var completionRate: Double {
        let attempts = completed + skipped
        return attempts == 0 ? 0 : Double(completed) / Double(attempts)
    }

    var shortDateLabel: String {
        guard let date = Self.keyFormatter.date(from: dateKey) else { return dateKey }
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.shared.locale
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter.string(from: date)
    }

    static func key(for date: Date, calendar: Calendar = .current) -> String {
        keyFormatter.calendar = calendar
        keyFormatter.timeZone = calendar.timeZone
        return keyFormatter.string(from: date)
    }

    private static let keyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

}
