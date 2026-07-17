import Foundation

final class SettingsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> ReminderSettings {
        guard
            let data = defaults.data(forKey: ReminderSettings.defaultsKey),
            var settings = try? JSONDecoder().decode(ReminderSettings.self, from: data)
        else {
            return .default
        }

        settings.clampToSupportedRanges()
        return settings
    }

    func save(_ settings: ReminderSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: ReminderSettings.defaultsKey)
    }
}

final class ActiveStateStore {
    private let defaults: UserDefaults
    private let key = "reminder.active-state.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> ActiveReminderState? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ActiveReminderState.self, from: data)
    }

    func save(_ state: ActiveReminderState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }
}

final class StatisticsStore {
    private let defaults: UserDefaults
    private let calendar: Calendar
    private let key = "reminder.daily-statistics.v1"
    private var records: [String: DailyStatistics]

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar

        if
            let data = defaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([String: DailyStatistics].self, from: data)
        {
            records = decoded
        } else {
            records = [:]
        }
    }

    func statistics(for date: Date) -> DailyStatistics {
        let dateKey = DailyStatistics.key(for: date, calendar: calendar)
        return records[dateKey] ?? DailyStatistics(dateKey: dateKey)
    }

    func recordFocus(seconds: Int, at date: Date) {
        guard seconds > 0 else { return }
        update(date) { $0.focusSeconds += seconds }
    }

    func recordCompleted(at date: Date) {
        update(date) { $0.completed += 1 }
    }

    func recordSkipped(at date: Date) {
        update(date) { $0.skipped += 1 }
    }

    func lastSevenDays(endingAt date: Date) -> [DailyStatistics] {
        (0..<7).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: date) else { return nil }
            return statistics(for: day)
        }
    }

    func currentStreak(at date: Date) -> Int {
        var count = 0
        var cursor = calendar.startOfDay(for: date)

        while statistics(for: cursor).completed > 0 {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return count
    }

    private func update(_ date: Date, mutation: (inout DailyStatistics) -> Void) {
        let dateKey = DailyStatistics.key(for: date, calendar: calendar)
        var item = records[dateKey] ?? DailyStatistics(dateKey: dateKey)
        mutation(&item)
        records[dateKey] = item
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: key)
    }
}
