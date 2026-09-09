import SwiftUI

struct RestView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image("RestLandscape")
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text(L10n.text("Take a break and relax your eyes"))
                        .font(.system(size: 14, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    Button {
                        model.endRestEarly()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)
                    .help(L10n.text("End early"))
                    .accessibilityLabel(L10n.text("End early"))
                }

                Text(L10n.format(
                    "Look at something at least %1$d feet (about %2$.1f meters) away",
                    model.settings.lookDistanceFeet,
                    model.settings.lookDistanceMeters
                ))
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                HStack {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        Text("\(max(0, Int(ceil(model.phase.deadline.timeIntervalSince(context.date))))) \(L10n.text("seconds"))")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .monospacedDigit()
                    }
                    Spacer(minLength: 8)
                    Button {
                        model.snoozeRest()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 15))
                            .frame(width: 26, height: 26)
                    }
                    .buttonStyle(.plain)
                    .help(L10n.text("Remind me in 5 minutes"))
                    .accessibilityLabel(L10n.text("Remind me in 5 minutes"))
                }
            }
        }
        .padding(16)
        .frame(width: 360, height: 156, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.primary.opacity(0.1))
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(L10n.text("Eye break countdown"))
        .environment(\.locale, localization.locale)
    }
}
