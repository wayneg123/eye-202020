import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                EyeMark(size: 92)

                VStack(spacing: 7) {
                    Text("EyeBreak 20-20-20")
                        .font(.system(size: 27, weight: .bold))
                    Text("版本 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("关于 20-20-20 法则")
                        .font(.headline)
                    Text("长时间使用屏幕后，定期看向远处并短暂放松，有助于养成更健康的用眼节奏。本应用负责温和地提醒你，但不能替代专业医疗建议。")
                        .foregroundStyle(.secondary)
                        .lineSpacing(5)
                }
                .padding(20)
                .eyeCard()

                VStack(alignment: .leading, spacing: 12) {
                    Label("隐私优先", systemImage: "lock.shield.fill")
                        .font(.headline)
                        .foregroundStyle(Color.eyeGreenDark)
                    Text("设置和统计只保存在这台 Mac 上。应用不需要账号，不上传使用记录，也不包含分析或广告 SDK。")
                        .foregroundStyle(.secondary)
                        .lineSpacing(5)
                }
                .padding(20)
                .eyeCard()

                Text("愿每一次抬头，都能看见更远的风景。")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(42)
            .frame(maxWidth: 660)
            .frame(maxWidth: .infinity)
        }
    }
}
