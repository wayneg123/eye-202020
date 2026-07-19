import Foundation

enum ReminderPhase: Codable, Equatable {
    case focusing(deadline: Date)
    case resting(deadline: Date)
    case snoozed(deadline: Date)

    var deadline: Date {
        switch self {
        case .focusing(let deadline), .resting(let deadline), .snoozed(let deadline):
            return deadline
        }
    }

    var isResting: Bool {
        if case .resting = self { return true }
        return false
    }

    var title: String {
        switch self {
        case .focusing: return L10n.text("Next break")
        case .resting: return L10n.text("Taking a break")
        case .snoozed: return L10n.text("Reminder snoozed")
        }
    }
}

struct ActiveReminderState: Codable, Equatable {
    var phase: ReminderPhase
    var focusStartedAt: Date?
}

enum ReminderTransition: Equatable {
    case restBegan(focusSeconds: Int)
    case restResumed
    case restCompleted
}
