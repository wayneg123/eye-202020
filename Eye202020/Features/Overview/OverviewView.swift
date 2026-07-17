import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                principleSection
                todaySection
                tip
            }
            .padding(34)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("20 20 20 原则")
                .font(.system(size: 26, weight: .bold))
            Text("每 \(model.settings.workMinutes) 分钟，看向 \(model.settings.lookDistanceFeet) 英尺（约 \(model.settings.lookDistanceMeters, specifier: "%.1f") 米）以外的地方，持续 \(model.settings.restSeconds) 秒，放松眼睛。")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }

    private var principleSection: some View {
        HStack(spacing: 30) {
            ZStack {
                ProgressRing(progress: model.progress, lineWidth: 12)
                VStack(spacing: 9) {
                    Text(model.phase.title)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    Text(model.formattedRemainingTime)
                        .font(.system(size: 45, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    if case .focusing = model.phase {
                        Button("跳过本次") { model.skipCurrent() }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                    }
                }
            }
            .frame(width: 270, height: 270)

            VStack(alignment: .leading, spacing: 24) {
                PrincipleRow(
                    icon: "clock",
                    title: "\(model.settings.workMinutes) 分钟",
                    subtitle: "专注工作"
                )
                PrincipleRow(
                    icon: "mountain.2.fill",
                    title: "\(model.settings.lookDistanceFeet) 英尺",
                    subtitle: "看向远方"
                )
                PrincipleRow(
                    icon: "eye.slash",
                    title: "\(model.settings.restSeconds) 秒",
                    subtitle: "放松眼睛"
                )

                Button {
                    model.startRestNow()
                } label: {
                    Label("立即休息", systemImage: "cup.and.saucer.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.eyeGreen)
            }
            .frame(maxWidth: 240)
        }
        .frame(maxWidth: .infinity)
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("今日统计")
                .font(.headline)

            HStack(spacing: 12) {
                StatCard(icon: "checkmark.circle", color: .eyeGreen, value: "\(model.today.completed)", label: "完成次数")
                StatCard(icon: "clock", color: .indigo, value: model.todayFocusDuration, label: "专注时长")
                StatCard(icon: "chart.line.uptrend.xyaxis", color: .eyeGreen, value: model.today.completionRate.formatted(.percent.precision(.fractionLength(0))), label: "完成率")
                StatCard(icon: "flame", color: .orange, value: "\(model.streak)", label: "连续天数")
            }
        }
        .padding(18)
        .eyeCard()
    }

    private var tip: some View {
        HStack(spacing: 13) {
            Image(systemName: "lightbulb.max.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 3) {
                Text("小贴士")
                    .font(.subheadline.weight(.semibold))
                Text("眨眨眼也能帮助眼睛保持湿润和放松哦 👀")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(15)
        .eyeCard()
    }
}

private struct PrincipleRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.eyeGreen.opacity(0.1))
                Image(systemName: icon)
                    .font(.system(size: 21))
                    .foregroundStyle(Color.eyeGreenDark.opacity(0.8))
            }
            .frame(width: 45, height: 45)

            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.medium))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

private struct StatCard: View {
    let icon: String
    let color: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 11))
    }
}
