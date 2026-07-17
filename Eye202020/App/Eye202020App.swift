import SwiftUI

@main
struct Eye202020App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup("EyeBreak 20-20-20", id: "main") {
            RootView()
                .environmentObject(model)
                .frame(minWidth: 880, minHeight: 620)
                .onAppear {
                    appDelegate.model = model
                    model.start()
                }
                .alert(
                    "操作未完成",
                    isPresented: Binding(
                        get: { model.presentedError != nil },
                        set: { if !$0 { model.presentedError = nil } }
                    ),
                    actions: { Button("好", role: .cancel) { model.presentedError = nil } },
                    message: { Text(model.presentedError ?? "未知错误") }
                )
        }
        .defaultSize(width: 960, height: 660)
        .windowResizability(.contentMinSize)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(model)
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
                .frame(width: 540, height: 480)
        }
    }
}
