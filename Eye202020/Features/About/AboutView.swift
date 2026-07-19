import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                EyeMark(size: 92)

                VStack(spacing: 7) {
                    Text("EyeBreak 20-20-20")
                        .font(.system(size: 27, weight: .bold))
                    Text(L10n.text("Version 1.0.0"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text(L10n.text("About the 20-20-20 rule"))
                        .font(.headline)
                    Text(L10n.text("After extended screen use, regularly looking into the distance and briefly relaxing can help you build healthier eye-care habits. This app provides gentle reminders, but it is not a substitute for professional medical advice."))
                        .foregroundStyle(.secondary)
                        .lineSpacing(5)
                }
                .padding(20)
                .eyeCard()

                VStack(alignment: .leading, spacing: 12) {
                    Label(L10n.text("Privacy first"), systemImage: "lock.shield.fill")
                        .font(.headline)
                        .foregroundStyle(Color.eyeGreenDark)
                    Text(L10n.text("Settings and statistics stay on this Mac. The app requires no account, uploads no usage records, and includes no analytics or advertising SDKs."))
                        .foregroundStyle(.secondary)
                        .lineSpacing(5)
                }
                .padding(20)
                .eyeCard()

                Text(L10n.text("May every glance up reveal a wider view."))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(42)
            .frame(maxWidth: 660)
            .frame(maxWidth: .infinity)
        }
    }
}
