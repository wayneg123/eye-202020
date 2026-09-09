import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    weak var model: AppModel?
    private var restWindowController: RestWindowController?
    private var observations: [NSObjectProtocol] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        let center = NotificationCenter.default
        observations.append(
            center.addObserver(forName: .showRestWindow, object: nil, queue: .main) { [weak self] note in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if let incomingModel = note.object as? AppModel {
                        self.model = incomingModel
                    }
                    guard let model = self.model, model.phase.isResting else { return }
                    self.showRestWindow(for: model)
                }
            }
        )
        observations.append(
            center.addObserver(forName: .closeRestWindow, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.restWindowController?.closeProgrammatically()
                    self?.restWindowController = nil
                }
            }
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        observations.forEach(NotificationCenter.default.removeObserver)
    }

    private func showRestWindow(for model: AppModel) {
        if let restWindowController {
            restWindowController.showWindow(nil)
            return
        }

        let controller = RestWindowController(model: model)
        restWindowController = controller
        controller.showWindow(nil)
    }
}

@MainActor
final class RestWindowController: NSWindowController, NSWindowDelegate {
    private weak var model: AppModel?
    private var isProgrammaticClose = false
    private var dismissalTask: Task<Void, Never>?

    init(model: AppModel) {
        self.model = model
        let localization = LocalizationManager.shared
        let rootView = RestView()
            .environmentObject(model)
            .environmentObject(localization)
            .environment(\.locale, localization.locale)
        let panel = RestNotificationPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 156),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = NSHostingView(rootView: rootView)
        panel.title = L10n.text("Take a break")
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.isReleasedWhenClosed = false
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true

        super.init(window: panel)
        panel.delegate = self
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func showWindow(_ sender: Any?) {
        guard let window else { return }
        let screen = NSScreen.screens.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }
            ?? NSScreen.main
        if let screen {
            window.setFrameOrigin(Self.origin(for: window.frame.size, in: screen.visibleFrame))
        }
        window.orderFrontRegardless()
        guard dismissalTask == nil else { return }
        // Hiding the banner must not end a longer, user-configured break.
        dismissalTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .seconds(20))
            } catch {
                return
            }
            self?.window?.orderOut(nil)
            self?.dismissalTask = nil
        }
    }

    static func origin(for size: NSSize, in visibleFrame: NSRect) -> NSPoint {
        NSPoint(
            x: max(visibleFrame.minX, visibleFrame.maxX - size.width - 16),
            y: max(visibleFrame.minY, visibleFrame.maxY - size.height - 16)
        )
    }

    func closeProgrammatically() {
        isProgrammaticClose = true
        dismissalTask?.cancel()
        dismissalTask = nil
        close()
    }

    func windowWillClose(_ notification: Notification) {
        if !isProgrammaticClose {
            model?.endRestEarly()
        }
    }
}

private final class RestNotificationPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
