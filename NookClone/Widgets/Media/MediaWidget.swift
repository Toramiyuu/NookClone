import SwiftUI

struct MediaWidgetView: View {

    @ObservedObject private var media = MediaManager.shared
    @StateObject private var spectrograph = AudioSpectrograph()
    @ObservedObject private var settings = MediaWidgetSettings.shared

    var body: some View {
        if let track = media.currentTrack {
            HStack(spacing: 12) {
                if settings.showArtwork {
                    AlbumCoverView(artwork: track.artwork)
                }

                VStack(alignment: .leading, spacing: 6) {
                    TrackInfoView(title: track.title, artist: track.artist, album: track.album)
                    PlaybackProgressView()
                    PlaybackControlsView()
                }

                if settings.showSpectrograph {
                    AudioSpectrographView(spectrograph: spectrograph, isActive: track.isPlaying)
                        .frame(maxWidth: 80)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(spacing: 10) {
                Image(systemName: "music.note.list")
                    .foregroundStyle(.white.opacity(0.3))
                Text("Nothing playing")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.3))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
