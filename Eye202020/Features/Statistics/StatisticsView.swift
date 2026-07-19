import Charts
import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.text("Statistics"))
                        .font(.system(size: 26, weight: .bold))
                    Text(L10n.text("Every glance into the distance is a little vacation for your eyes."))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 14) {
                    SummaryTile(title: L10n.text("Completed today"), value: L10n.format("%d times", model.today.completed), icon: "checkmark.circle.fill", color: .eyeGreen)
                    SummaryTile(title: L10n.text("Skipped today"), value: L10n.format("%d times", model.today.skipped), icon: "forward.end.fill", color: .orange)
                    SummaryTile(title: L10n.text("Current streak"), value: L10n.format("%d days", model.streak), icon: "flame.fill", color: .red)
                }

                VStack(alignment: .leading, spacing: 18) {
                    Text(L10n.text("Last 7 days"))
                        .font(.headline)

                    Chart(model.recentStatistics) { item in
                        BarMark(
                            x: .value(L10n.text("Date"), item.shortDateLabel),
                            y: .value(L10n.text("Completed"), item.completed)
                        )
                        .foregroundStyle(Color.eyeGreen.gradient)
                        .cornerRadius(5)

                        BarMark(
                            x: .value(L10n.text("Date"), item.shortDateLabel),
                            y: .value(L10n.text("Skipped"), item.skipped)
                        )
                        .foregroundStyle(Color.orange.opacity(0.58))
                        .cornerRadius(5)
                    }
                    .chartForegroundStyleScale([
                        L10n.text("Completed"): Color.eyeGreen,
                        L10n.text("Skipped"): Color.orange.opacity(0.58)
                    ])
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 4))
                    }
                    .frame(height: 260)
                }
                .padding(20)
                .eyeCard()

                HStack {
                    Label(L10n.text("Green represents completed breaks; orange represents breaks ended early or skipped."), systemImage: "info.circle")
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
