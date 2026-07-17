import AppKit
import Foundation

@MainActor
final class SystemActivityMonitor {
    private var observations: [NSObjectProtocol] = []
    private var isInactive = false
    private var onInactive: (() -> Void)?
    private var onResume: (() -> Void)?

    func start(onInactive: @escaping () -> Void, onResume: @escaping () -> Void) {
        guard observations.isEmpty else { return }
        self.onInactive = onInactive
        self.onResume = onResume

        let center = NSWorkspace.shared.notificationCenter
        let inactiveNames: [NSNotification.Name] = [
            NSWorkspace.willSleepNotification,
            NSWorkspace.sessionDidResignActiveNotification,
            NSWorkspace.screensDidSleepNotification
        ]
        let resumeNames: [NSNotification.Name] = [
            NSWorkspace.didWakeNotification,
            NSWorkspace.sessionDidBecomeActiveNotification,
            NSWorkspace.screensDidWakeNotification
        ]

        observations += inactiveNames.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self, !self.isInactive else { return }
                    self.isInactive = true
                    self.onInactive?()
                }
            }
        }

        observations += resumeNames.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self, self.isInactive else { return }
                    self.isInactive = false
                    self.onResume?()
                }
            }
        }
    }

    deinit {
        let center = NSWorkspace.shared.notificationCenter
        observations.forEach(center.removeObserver)
    }
}

extension Notification.Name {
    static let showRestWindow = Notification.Name("eye202020.showRestWindow")
    static let closeRestWindow = Notification.Name("eye202020.closeRestWindow")
}
