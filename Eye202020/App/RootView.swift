import SwiftUI

private enum AppSection: String, CaseIterable, Identifiable {
    case overview = "概览"
    case statistics = "统计"
    case settings = "设置"
    case about = "关于"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .overview: return "house"
        case .statistics: return "chart.bar.xaxis"
        case .settings: return "gearshape"
        case .about: return "info.circle"
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selection: AppSection = .overview

    var body: some View {
        HStack(spacing: 0) {
            sidebar
                .frame(width: 235)

            Group {
                switch selection {
                case .overview:
                    OverviewView()
                case .statistics:
                    StatisticsView()
                case .settings:
                    SettingsView()
                case .about:
                    AboutView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.84))
        }
        .background(.ultraThinMaterial)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                EyeMark(size: 46)
                VStack(alignment: .leading, spacing: 3) {
                    Text("EyeBreak 20-20-20")
                        .font(.headline)
                    Text("好习惯，亮眼睛")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 30)

            VStack(spacing: 8) {
                ForEach(AppSection.allCases) { section in
                    Button {
                        selection = section
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: section.icon)
                                .font(.system(size: 17, weight: .medium))
                                .frame(width: 22)
                            Text(section.rawValue)
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                        .foregroundStyle(selection == section ? Color.eyeGreenDark : Color.primary.opacity(0.78))
                        .padding(.horizontal, 14)
                        .frame(height: 43)
                        .background(
                            selection == section ? Color.eyeGreen.opacity(0.12) : .clear,
                            in: RoundedRectangle(cornerRadius: 9, style: .continuous)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundStyle(Color.eyeGreen.opacity(0.55))
                Text("你的眼睛值得\n每 20 分钟的关心。")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineSpacing(5)
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 28)

            Divider().opacity(0.45)

            Toggle(
                "开机时启动",
                isOn: Binding(
                    get: { model.settings.launchAtLogin },
                    set: model.setLaunchAtLogin
                )
            )
            .toggleStyle(.switch)
            .controlSize(.small)
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [Color.eyeMint.opacity(0.9), Color.white.opacity(0.36)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
