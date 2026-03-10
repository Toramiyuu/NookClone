import SwiftUI

struct VolumeIndicatorView: View {
    let value: Float   // 0.0 – 1.0
    let isMuted: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isMuted ? "speaker.slash.fill" : speakerIcon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 28)

            LevelBar(value: CGFloat(value), color: .white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
        .frame(width: 280, height: 72)
    }

    private var speakerIcon: String {
        switch value {
        case 0: return "speaker.slash.fill"
        case ..<0.33: return "speaker.fill"
        case ..<0.66: return "speaker.wave.1.fill"
        default: return "speaker.wave.3.fill"
        }
    }
}

struct BrightnessIndicatorView: View {
    let value: Float

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 28)

            LevelBar(value: CGFloat(value), color: .yellow)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
        .frame(width: 280, height: 72)
    }
}

struct LevelBar: View {
    let value: CGFloat  // 0.0 – 1.0
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.15))

                Capsule()
                    .fill(color)
                    .frame(width: max(0, geo.size.width * value))
                    .animation(.spring(response: 0.2), value: value)
            }
        }
        .frame(height: 10)
    }
}
