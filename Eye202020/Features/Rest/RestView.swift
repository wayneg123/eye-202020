import SwiftUI

struct RestView: View {
    @EnvironmentObject private var model: AppModel

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
                    .help("提前结束")

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

                    Text("休息一下，放松眼睛")
                        .font(.system(size: 23, weight: .semibold))
                    Text("请看向 \(model.settings.lookDistanceFeet) 英尺（约 \(model.settings.lookDistanceMeters, specifier: "%.1f") 米）以外的地方")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(model.remainingSeconds)")
                            .font(.system(size: 44, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                        Text("秒")
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(.top, 5)

                    HStack(spacing: 12) {
                        Button("5 分钟后提醒") {
                            model.snoozeRest()
                        }
                        .buttonStyle(.bordered)

                        Button("提前结束") {
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
        .accessibilityLabel("护眼休息倒计时")
    }
}
