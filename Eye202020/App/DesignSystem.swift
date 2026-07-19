import SwiftUI

extension Color {
    static let eyeGreen = Color(red: 0.12, green: 0.58, blue: 0.43)
    static let eyeGreenDark = Color(red: 0.08, green: 0.38, blue: 0.30)
    static let eyeMint = Color(red: 0.86, green: 0.95, blue: 0.91)
    static let eyeTextSecondary = Color.primary.opacity(0.58)
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.68), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.035), radius: 12, y: 5)
    }
}

extension View {
    func eyeCard() -> some View {
        modifier(CardBackground())
    }
}

struct EyeMark: View {
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.eyeGreen.opacity(0.13))
            Image(systemName: "eye.fill")
                .font(.system(size: size * 0.52, weight: .semibold))
                .foregroundStyle(Color.eyeGreen)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.eyeGreen.opacity(0.16), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color.eyeGreen.opacity(0.55), Color.eyeGreen],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}
