import AppKit
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 9) {
                EyeMark(size: 31)
                Text("EyeBreak 20-20-20")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Button {
                    openMainWindow()
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
                .help("打开应用")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(model.phase.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(model.formattedRemainingTime)
                            .font(.system(size: 29, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.eyeGreen)
                            .monospacedDigit()
                    }
                    Spacer()
                    ZStack {
                        ProgressRing(progress: model.progress, lineWidth: 5)
                        Image(systemName: model.phase.isResting ? "eye.slash" : "cup.and.saucer.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.eyeGreenDark)
                    }
                    .frame(width: 55, height: 55)
                }

                Button {
                    model.startRestNow()
                } label: {
                    Text(model.phase.isResting ? "返回休息" : "开始休息")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.eyeGreen)
                .controlSize(.large)

                Button {
                    openMainWindow()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(Color.eyeGreen)
                        Text("今日完成 \(model.today.completed) 次")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .font(.system(size: 13))
                .padding(10)
                .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 9))
            }
            .padding(14)

            Divider()

            HStack(spacing: 0) {
                Button("打开应用") { openMainWindow() }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                Divider().frame(height: 19)
                Button("退出") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
            }
            .font(.system(size: 13))
            .padding(.vertical, 11)
        }
        .frame(width: 250)
        .background(.ultraThinMaterial)
    }

    private func openMainWindow() {
        openWindow(id: "main")
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
