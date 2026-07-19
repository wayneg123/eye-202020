import AppKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.text("Settings"))
                        .font(.system(size: 26, weight: .bold))
                    Text(L10n.text("Adjust the work and rest rhythm that suits you."))
                        .foregroundStyle(.secondary)
                }

                settingsGroup(L10n.text("20-20-20 rule"), icon: "timer") {
                    StepperRow(
                        title: L10n.text("Work duration"),
                        detail: L10n.text("Focus time between breaks"),
                        value: Binding(
                            get: { model.settings.workMinutes },
                            set: { value in model.updateSettings { $0.workMinutes = value } }
                        ),
                        range: 1...120,
                        suffix: L10n.text("min")
                    )
                    Divider()
                    StepperRow(
                        title: L10n.text("Viewing distance"),
                        detail: L10n.text("Minimum suggested distance to look at during a break"),
                        value: Binding(
                            get: { model.settings.lookDistanceFeet },
                            set: { value in model.updateSettings { $0.lookDistanceFeet = value } }
                        ),
                        range: 5...100,
                        suffix: L10n.text("ft")
                    )
                    Divider()
                    StepperRow(
                        title: L10n.text("Break duration"),
                        detail: L10n.text("Countdown for each distance-viewing break"),
                        value: Binding(
                            get: { model.settings.restSeconds },
                            set: { value in model.updateSettings { $0.restSeconds = value } }
                        ),
                        range: 5...120,
                        suffix: L10n.text("sec")
                    )
                }

                settingsGroup(L10n.text("Reminders and system"), icon: "bell") {
                    ToggleRow(
                        title: L10n.text("Notification sound"),
                        detail: model.notificationPermissionLabel,
                        isOn: Binding(
                            get: { model.settings.notificationSoundEnabled },
                            set: { value in model.updateSettings { $0.notificationSoundEnabled = value } }
                        )
                    )
                    Divider()
                    ToggleRow(
                        title: L10n.text("Launch at login"),
                        detail: L10n.text("Start the eye-care timer automatically after logging in to your Mac"),
                        isOn: Binding(
                            get: { model.settings.launchAtLogin },
                            set: model.setLaunchAtLogin
                        )
                    )
                }

                HStack {
                    Button(L10n.text("Restore defaults")) {
                        model.restoreDefaultSettings()
                    }
                    Spacer()
                    Button(L10n.text("Open system notification settings")) {
                        guard let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") else { return }
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            .padding(34)
            .frame(maxWidth: 760, alignment: .leading)
        }
        .task { await model.refreshNotificationPermission() }
    }

    private func settingsGroup<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color.eyeGreenDark)
            content()
        }
        .padding(18)
        .eyeCard()
    }
}

private struct StepperRow: View {
    let title: String
    let detail: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let suffix: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.medium))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(value) \(suffix)")
                .font(.system(.body, design: .rounded).weight(.medium))
                .frame(minWidth: 70, alignment: .trailing)
            Stepper("", value: $value, in: range)
                .labelsHidden()
        }
        .padding(.vertical, 2)
    }
}

private struct ToggleRow: View {
    let title: String
    let detail: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.medium))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.switch)
        .tint(.eyeGreen)
    }
}
