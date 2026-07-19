import SwiftUI

@main
struct Eye202020App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()
    @StateObject private var localization = LocalizationManager.shared

    var body: some Scene {
        WindowGroup("EyeBreak 20-20-20", id: "main") {
            RootView()
                .environmentObject(model)
                .environmentObject(localization)
                .environment(\.locale, localization.locale)
                .frame(minWidth: 880, minHeight: 620)
                .onAppear {
                    appDelegate.model = model
                    model.start()
                }
                .alert(
                    L10n.text("The operation could not be completed"),
                    isPresented: Binding(
                        get: { model.presentedError != nil },
                        set: { if !$0 { model.presentedError = nil } }
                    ),
                    actions: { Button(L10n.text("OK"), role: .cancel) { model.presentedError = nil } },
                    message: { Text(model.presentedError ?? L10n.text("Unknown error")) }
                )
        }
        .defaultSize(width: 960, height: 660)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(model)
                .environmentObject(localization)
                .environment(\.locale, localization.locale)
                .onAppear {
                    appDelegate.model = model
                    model.start()
                }
        } label: {
            Image(systemName: "eye.fill")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(model)
                .environmentObject(localization)
                .environment(\.locale, localization.locale)
                .frame(width: 540, height: 480)
        }
    }
}
