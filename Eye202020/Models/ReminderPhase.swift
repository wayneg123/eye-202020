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
        case .focusing: return "下次休息"
        case .resting: return "正在休息"
        case .snoozed: return "稍后提醒"
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
