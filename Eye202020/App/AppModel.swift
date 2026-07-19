import Foundation
import UserNotifications

protocol DateProviding {
    var now: Date { get }
}

struct SystemDateProvider: DateProviding {
    var now: Date { Date() }
}

@MainActor
final class AppModel: ObservableObject {
    enum NotificationPermission {
        case unknown
        case enabled
        case denied
    }

    @Published private(set) var settings: ReminderSettings
    @Published private(set) var phase: ReminderPhase
    private(set) var now: Date
    @Published private(set) var statisticsRevision = 0
    @Published private(set) var notificationPermission: NotificationPermission = .unknown
    @Published var presentedError: String?

    private var engine: ReminderEngine
    private let settingsStore: SettingsStore
    private let activeStateStore: ActiveStateStore
    private let statisticsStore: StatisticsStore
    private let notificationService: ReminderNotificationServing
    private let launchAtLoginService: LaunchAtLoginServing
    private let activityMonitor: SystemActivityMonitor
    private let dateProvider: DateProviding
    private var timer: Timer?
    private var hasStarted = false
    private var isSystemInactive = false
    private var currentDayKey: String

    init(
        settingsStore: SettingsStore = SettingsStore(),
        activeStateStore: ActiveStateStore = ActiveStateStore(),
        statisticsStore: StatisticsStore = StatisticsStore(),
        notificationService: ReminderNotificationServing = NotificationService(),
        launchAtLoginService: LaunchAtLoginServing = LaunchAtLoginService(),
        activityMonitor: SystemActivityMonitor? = nil,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        let now = dateProvider.now
        let loadedSettings = settingsStore.load()
        var reconciledSettings = loadedSettings
        reconciledSettings.launchAtLogin = launchAtLoginService.isEnabled
        settingsStore.save(reconciledSettings)

        self.now = now
        settings = reconciledSettings
        self.settingsStore = settingsStore
        self.activeStateStore = activeStateStore
        self.statisticsStore = statisticsStore
        self.notificationService = notificationService
        self.launchAtLoginService = launchAtLoginService
        self.activityMonitor = activityMonitor ?? SystemActivityMonitor()
        self.dateProvider = dateProvider
        currentDayKey = DailyStatistics.key(for: now)

        engine = ReminderEngine(
            settings: reconciledSettings,
            now: now,
            restoredState: activeStateStore.load()
        )
        phase = engine.phase
        persist()
    }

    deinit {
        timer?.invalidate()
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        activityMonitor.start(
            onInactive: { [weak self] in self?.beginInactivity() },
            onResume: { [weak self] in self?.resetAfterInactivity() }
        )

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.processTimerTick() }
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }

        Task {
            await notificationService.requestAuthorization()
            await refreshNotificationPermission()
        }

        if phase.isResting {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .showRestWindow, object: self)
            }
        }
    }

    var remainingSeconds: Int {
        engine.remainingSeconds(at: now)
    }

    var formattedRemainingTime: String {
        let remaining = remainingSeconds
        return String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    var progress: Double {
        let total: Double
        switch phase {
        case .focusing:
            total = Double(settings.workMinutes * 60)
        case .resting:
            total = Double(settings.restSeconds)
        case .snoozed:
            total = 300
        }
        guard total > 0 else { return 0 }
        return min(max(1 - Double(remainingSeconds) / total, 0), 1)
    }

    var today: DailyStatistics {
        statisticsStore.statistics(for: now)
    }

    var recentStatistics: [DailyStatistics] {
        statisticsStore.lastSevenDays(endingAt: now)
    }

    var streak: Int {
        statisticsStore.currentStreak(at: now)
    }

    var todayFocusDuration: String {
        let totalMinutes = today.focusSeconds / 60
        return L10n.format("%1$dh %2$dm", totalMinutes / 60, totalMinutes % 60)
    }

    var notificationPermissionLabel: String {
        switch notificationPermission {
        case .unknown: return L10n.text("Checking")
        case .enabled: return L10n.text("Allowed")
        case .denied: return L10n.text("Not allowed (the break window will still appear)")
        }
    }

    func startRestNow() {
        let timestamp = dateProvider.now
        now = timestamp

        if phase.isResting {
            NotificationCenter.default.post(name: .showRestWindow, object: self)
            return
        }

        let focusSeconds = engine.startRestNow(at: timestamp)
        statisticsStore.recordFocus(seconds: focusSeconds, at: timestamp)
        statisticsRevision += 1
        syncFromEngine()
        NotificationCenter.default.post(name: .showRestWindow, object: self)
    }

    func skipCurrent() {
        if phase.isResting {
            endRestEarly()
            return
        }

        let timestamp = dateProvider.now
        let focusSeconds = engine.skipCurrent(at: timestamp)
        statisticsStore.recordFocus(seconds: focusSeconds, at: timestamp)
        statisticsStore.recordSkipped(at: timestamp)
        statisticsRevision += 1
        now = timestamp
        syncFromEngine()
        NotificationCenter.default.post(name: .closeRestWindow, object: nil)
    }

    func snoozeRest() {
        guard phase.isResting else { return }
        let timestamp = dateProvider.now
        engine.snooze(at: timestamp)
        now = timestamp
        syncFromEngine()
        NotificationCenter.default.post(name: .closeRestWindow, object: nil)
    }

    func endRestEarly() {
        guard phase.isResting else { return }
        let timestamp = dateProvider.now
        statisticsStore.recordSkipped(at: timestamp)
        statisticsRevision += 1
        engine.finishRest(at: timestamp)
        now = timestamp
        syncFromEngine()
        NotificationCenter.default.post(name: .closeRestWindow, object: nil)
    }

    func updateSettings(_ update: (inout ReminderSettings) -> Void) {
        let timestamp = dateProvider.now
        var updated = settings
        update(&updated)
        updated.clampToSupportedRanges()
        settings = updated
        now = timestamp
        settingsStore.save(updated)
        engine.updateSettings(updated, at: timestamp)
        syncFromEngine()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try launchAtLoginService.setEnabled(enabled)
            settings.launchAtLogin = launchAtLoginService.isEnabled
            settingsStore.save(settings)
        } catch {
            settings.launchAtLogin = launchAtLoginService.isEnabled
            presentedError = L10n.format("Unable to update launch at login: %@", error.localizedDescription)
        }
    }

    func restoreDefaultSettings() {
        let timestamp = dateProvider.now
        let defaults = ReminderSettings.default
        do {
            try launchAtLoginService.setEnabled(defaults.launchAtLogin)
        } catch {
            presentedError = L10n.format("Unable to disable launch at login: %@", error.localizedDescription)
        }

        settings = defaults
        settings.launchAtLogin = launchAtLoginService.isEnabled
        now = timestamp
        settingsStore.save(settings)
        engine.updateSettings(settings, at: timestamp)
        syncFromEngine()
    }

    func refreshNotificationPermission() async {
        let status = await notificationService.authorizationStatus()
        switch status {
        case .authorized, .provisional, .ephemeral:
            notificationPermission = .enabled
        case .denied:
            notificationPermission = .denied
        default:
            notificationPermission = .unknown
        }
    }

    func processTimerTick() {
        let timestamp = dateProvider.now
        now = timestamp

        let dayKey = DailyStatistics.key(for: timestamp)
        if dayKey != currentDayKey {
            currentDayKey = dayKey
            statisticsRevision += 1
        }

        guard !isSystemInactive else { return }

        guard let transition = engine.tick(at: timestamp) else { return }
        syncFromEngine()

        switch transition {
        case .restBegan(let focusSeconds):
            statisticsStore.recordFocus(seconds: focusSeconds, at: timestamp)
            statisticsRevision += 1
            showDueRestReminder()

        case .restResumed:
            showDueRestReminder()

        case .restCompleted:
            statisticsStore.recordCompleted(at: timestamp)
            statisticsRevision += 1
            NotificationCenter.default.post(name: .closeRestWindow, object: nil)
        }
    }

    private func showDueRestReminder() {
        notificationService.sendRestReminder(soundEnabled: settings.notificationSoundEnabled)
        NotificationCenter.default.post(name: .showRestWindow, object: self)
    }

    private func resetAfterInactivity() {
        let timestamp = dateProvider.now
        isSystemInactive = false
        now = timestamp
        engine.resetAfterInactivity(at: timestamp)
        syncFromEngine()
        NotificationCenter.default.post(name: .closeRestWindow, object: nil)
    }

    private func beginInactivity() {
        isSystemInactive = true
        NotificationCenter.default.post(name: .closeRestWindow, object: nil)
    }

    private func syncFromEngine() {
        phase = engine.phase
        persist()
    }

    private func persist() {
        activeStateStore.save(engine.activeState)
    }
}
