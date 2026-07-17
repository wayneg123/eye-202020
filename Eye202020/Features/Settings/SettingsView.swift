import AppKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("设置")
                        .font(.system(size: 26, weight: .bold))
                    Text("调整适合你的工作与休息节奏。")
                        .foregroundStyle(.secondary)
                }

                settingsGroup("20 20 20 规则", icon: "timer") {
                    StepperRow(
                        title: "工作时长",
                        detail: "两次休息之间的专注时间",
                        value: Binding(
                            get: { model.settings.workMinutes },
                            set: { value in model.updateSettings { $0.workMinutes = value } }
                        ),
                        range: 1...120,
                        suffix: "分钟"
                    )
                    Divider()
                    StepperRow(
                        title: "观察距离",
                        detail: "提醒时建议眺望的最短距离",
                        value: Binding(
                            get: { model.settings.lookDistanceFeet },
                            set: { value in model.updateSettings { $0.lookDistanceFeet = value } }
                        ),
                        range: 5...100,
                        suffix: "英尺"
                    )
                    Divider()
                    StepperRow(
                        title: "休息时长",
                        detail: "每次眺望远方的倒计时",
                        value: Binding(
                            get: { model.settings.restSeconds },
                            set: { value in model.updateSettings { $0.restSeconds = value } }
                        ),
                        range: 5...120,
                        suffix: "秒"
                    )
                }

                settingsGroup("提醒与系统", icon: "bell") {
                    ToggleRow(
                        title: "通知声音",
                        detail: model.notificationPermissionLabel,
                        isOn: Binding(
                            get: { model.settings.notificationSoundEnabled },
                            set: { value in model.updateSettings { $0.notificationSoundEnabled = value } }
                        )
                    )
                    Divider()
                    ToggleRow(
                        title: "开机时启动",
                        detail: "登录 Mac 后自动开始护眼计时",
                        isOn: Binding(
                            get: { model.settings.launchAtLogin },
                            set: model.setLaunchAtLogin
                        )
                    )
                }

                HStack {
                    Button("恢复默认设置") {
                        model.restoreDefaultSettings()
                    }
                    Spacer()
                    Button("打开系统通知设置") {
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
