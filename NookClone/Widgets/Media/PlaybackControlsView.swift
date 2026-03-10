import SwiftUI

/// Prev / Play-Pause / Next control strip.
struct PlaybackControlsView: View {

    @ObservedObject private var media = MediaManager.shared

    var body: some View {
        HStack(spacing: 20) {
            controlButton(systemImage: "backward.fill") {
                media.previousTrack()
            }

            controlButton(systemImage: media.isPlaying ? "pause.fill" : "play.fill", size: 20) {
                media.togglePlayPause()
            }

            controlButton(systemImage: "forward.fill") {
                media.nextTrack()
            }
        }
    }

    private func controlButton(
        systemImage: String,
        size: CGFloat = 14,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(.white.opacity(0.1), in: Circle())
        }
        .buttonStyle(.plain)
    }
}

/// Thin progress bar showing playback position.
struct PlaybackProgressView: View {

    @ObservedObject private var media = MediaManager.shared

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.15))
                    .frame(height: 3)

                Capsule()
                    .fill(.white.opacity(0.7))
                    .frame(width: geo.size.width * CGFloat(media.progress), height: 3)
                    .animation(.linear(duration: 1), value: media.progress)
            }
        }
        .frame(height: 3)
    }
}
