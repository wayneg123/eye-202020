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
            restWindowController.window?.makeKeyAndOrderFront(nil)
            return
        }

        let controller = RestWindowController(model: model)
        restWindowController = controller
        controller.showWindow(nil)
    }
}

@MainActor
private final class RestWindowController: NSWindowController, NSWindowDelegate {
    private weak var model: AppModel?
    private var isProgrammaticClose = false

    init(model: AppModel) {
        self.model = model
        let localization = LocalizationManager.shared
        let rootView = RestView()
            .environmentObject(model)
            .environmentObject(localization)
            .environment(\.locale, localization.locale)
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 420),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.contentView = NSHostingView(rootView: rootView)
        panel.title = L10n.text("Take a break")
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.center()

        super.init(window: panel)
        panel.delegate = self
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeProgrammatically() {
        isProgrammaticClose = true
        close()
    }

    func windowWillClose(_ notification: Notification) {
        if !isProgrammaticClose {
            model?.endRestEarly()
        }
    }
}
