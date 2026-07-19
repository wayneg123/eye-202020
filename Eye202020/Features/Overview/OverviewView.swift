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
            Text(L10n.text("The 20-20-20 rule"))
                .font(.system(size: 26, weight: .bold))
            Text(L10n.format(
                "Every %1$d minutes, look at something at least %2$d feet (about %3$.1f meters) away for %4$d seconds to relax your eyes.",
                model.settings.workMinutes,
                model.settings.lookDistanceFeet,
                model.settings.lookDistanceMeters,
                model.settings.restSeconds
            ))
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }

    private var principleSection: some View {
        HStack(spacing: 30) {
            TimelineView(.periodic(from: .now, by: 1)) { _ in
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
                            Button(L10n.text("Skip this break")) { model.skipCurrent() }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                        }
                    }
                }
            }
            .frame(width: 270, height: 270)

            VStack(alignment: .leading, spacing: 24) {
                PrincipleRow(
                    icon: "clock",
                    title: L10n.format("%d minutes", model.settings.workMinutes),
                    subtitle: L10n.text("Focused work")
                )
                PrincipleRow(
                    icon: "mountain.2.fill",
                    title: L10n.format("%d feet", model.settings.lookDistanceFeet),
                    subtitle: L10n.text("Look into the distance")
                )
                PrincipleRow(
                    icon: "eye.slash",
                    title: L10n.format("%d seconds", model.settings.restSeconds),
                    subtitle: L10n.text("Relax your eyes")
                )

                Button {
                    model.startRestNow()
                } label: {
                    Label(L10n.text("Take a break now"), systemImage: "cup.and.saucer.fill")
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
            Text(L10n.text("Today's statistics"))
                .font(.headline)

            HStack(spacing: 12) {
                StatCard(icon: "checkmark.circle", color: .eyeGreen, value: "\(model.today.completed)", label: L10n.text("Completed"))
                StatCard(icon: "clock", color: .indigo, value: model.todayFocusDuration, label: L10n.text("Focus time"))
                StatCard(icon: "chart.line.uptrend.xyaxis", color: .eyeGreen, value: model.today.completionRate.formatted(.percent.precision(.fractionLength(0))), label: L10n.text("Completion rate"))
                StatCard(icon: "flame", color: .orange, value: "\(model.streak)", label: L10n.text("Day streak"))
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
                Text(L10n.text("Tip"))
                    .font(.subheadline.weight(.semibold))
                Text(L10n.text("Blinking also helps keep your eyes moist and relaxed 👀"))
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
