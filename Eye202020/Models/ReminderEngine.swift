import Foundation

struct ReminderEngine {
    private(set) var settings: ReminderSettings
    private(set) var phase: ReminderPhase
    private(set) var focusStartedAt: Date?

    init(settings: ReminderSettings, now: Date = Date(), restoredState: ActiveReminderState? = nil) {
        self.settings = settings

        if let restoredState, restoredState.phase.deadline > now {
            phase = restoredState.phase
            focusStartedAt = restoredState.focusStartedAt
        } else {
            phase = .focusing(deadline: now.addingTimeInterval(settings.workInterval))
            focusStartedAt = now
        }
    }

    var activeState: ActiveReminderState {
        ActiveReminderState(phase: phase, focusStartedAt: focusStartedAt)
    }

    func remainingSeconds(at now: Date) -> Int {
        max(0, Int(ceil(phase.deadline.timeIntervalSince(now))))
    }

    mutating func tick(at now: Date) -> ReminderTransition? {
        guard now >= phase.deadline else { return nil }

        switch phase {
        case .focusing:
            let elapsed = elapsedFocusSeconds(at: now)
            phase = .resting(deadline: now.addingTimeInterval(settings.restInterval))
            focusStartedAt = nil
            return .restBegan(focusSeconds: elapsed)

        case .snoozed:
            phase = .resting(deadline: now.addingTimeInterval(settings.restInterval))
            return .restResumed

        case .resting:
            beginNewFocus(at: now)
            return .restCompleted
        }
    }

    mutating func startRestNow(at now: Date) -> Int {
        let elapsed = elapsedFocusSeconds(at: now)
        phase = .resting(deadline: now.addingTimeInterval(settings.restInterval))
        focusStartedAt = nil
        return elapsed
    }

    mutating func snooze(at now: Date, seconds: TimeInterval = 300) {
        phase = .snoozed(deadline: now.addingTimeInterval(seconds))
        focusStartedAt = nil
    }

    mutating func finishRest(at now: Date) {
        beginNewFocus(at: now)
    }

    mutating func skipCurrent(at now: Date) -> Int {
        let elapsed = elapsedFocusSeconds(at: now)
        beginNewFocus(at: now)
        return elapsed
    }

    mutating func resetAfterInactivity(at now: Date) {
        beginNewFocus(at: now)
    }

    mutating func updateSettings(_ newSettings: ReminderSettings, at now: Date) {
        let workDurationChanged = settings.workMinutes != newSettings.workMinutes
        settings = newSettings

        if workDurationChanged, case .focusing = phase {
            beginNewFocus(at: now)
        }
    }

    private mutating func beginNewFocus(at now: Date) {
        phase = .focusing(deadline: now.addingTimeInterval(settings.workInterval))
        focusStartedAt = now
    }

    private func elapsedFocusSeconds(at now: Date) -> Int {
        guard case .focusing = phase, let focusStartedAt else { return 0 }
        return max(0, min(Int(now.timeIntervalSince(focusStartedAt)), Int(settings.workInterval)))
    }
}

private extension ReminderSettings {
    var workInterval: TimeInterval { TimeInterval(workMinutes * 60) }
    var restInterval: TimeInterval { TimeInterval(restSeconds) }
}
