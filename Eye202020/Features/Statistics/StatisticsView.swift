import Charts
import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("统计")
                        .font(.system(size: 26, weight: .bold))
                    Text("每一次眺望远方，都是给眼睛的小假期。")
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 14) {
                    SummaryTile(title: "今日完成", value: "\(model.today.completed) 次", icon: "checkmark.circle.fill", color: .eyeGreen)
                    SummaryTile(title: "今日跳过", value: "\(model.today.skipped) 次", icon: "forward.end.fill", color: .orange)
                    SummaryTile(title: "连续记录", value: "\(model.streak) 天", icon: "flame.fill", color: .red)
                }

                VStack(alignment: .leading, spacing: 18) {
                    Text("最近 7 天")
                        .font(.headline)

                    Chart(model.recentStatistics) { item in
                        BarMark(
                            x: .value("日期", item.shortDateLabel),
                            y: .value("完成", item.completed)
                        )
                        .foregroundStyle(Color.eyeGreen.gradient)
                        .cornerRadius(5)

                        BarMark(
                            x: .value("日期", item.shortDateLabel),
                            y: .value("跳过", item.skipped)
                        )
                        .foregroundStyle(Color.orange.opacity(0.58))
                        .cornerRadius(5)
                    }
                    .chartForegroundStyleScale([
                        "完成": Color.eyeGreen,
                        "跳过": Color.orange.opacity(0.58)
                    ])
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 4))
                    }
                    .frame(height: 260)
                }
                .padding(20)
                .eyeCard()

                HStack {
                    Label("绿色代表完整完成休息，橙色代表提前结束或跳过。", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            .padding(34)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }
}

private struct SummaryTile: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.1), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(value).font(.title3.weight(.semibold))
                Text(title).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .eyeCard()
    }
}
