import SwiftUI

struct RestView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        ZStack {
            Image("RestLandscape")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            LinearGradient(
                colors: [
                    Color.white.opacity(0.18),
                    Color.white.opacity(0.52),
                    Color.white.opacity(0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                HStack {
                    Button {
                        model.endRestEarly()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 27, height: 27)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .help(L10n.text("End early"))

                    Spacer()
                }
                .padding(16)

                Spacer()

                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                        Image(systemName: "eye.slash")
                            .font(.system(size: 34, weight: .medium))
                    }
                    .frame(width: 82, height: 82)

                    Text(L10n.text("Take a break and relax your eyes"))
                        .font(.system(size: 23, weight: .semibold))
                    Text(L10n.format(
                        "Look at something at least %1$d feet (about %2$.1f meters) away",
                        model.settings.lookDistanceFeet,
                        model.settings.lookDistanceMeters
                    ))
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(model.remainingSeconds)")
                                .font(.system(size: 44, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                            Text(L10n.text("seconds"))
                                .font(.subheadline.weight(.medium))
                        }
                    }
                    .padding(.top, 5)

                    HStack(spacing: 12) {
                        Button(L10n.text("Remind me in 5 minutes")) {
                            model.snoozeRest()
                        }
                        .buttonStyle(.bordered)

                        Button(L10n.text("End early")) {
                            model.endRestEarly()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white.opacity(0.92))
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 35)
                .padding(.vertical, 24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.bottom, 28)

                Spacer(minLength: 8)
            }
        }
        .frame(width: 640, height: 420)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(L10n.text("Eye break countdown"))
        .environment(\.locale, localization.locale)
    }
}
