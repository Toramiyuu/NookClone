import SwiftUI

/// Rounded square album artwork with drop shadow and placeholder.
struct AlbumCoverView: View {

    let artwork: NSImage?
    let size: CGFloat

    init(artwork: NSImage?, size: CGFloat = 60) {
        self.artwork = artwork
        self.size = size
    }

    var body: some View {
        Group {
            if let artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Color.white.opacity(0.08)
                    Image(systemName: "music.note")
                        .font(.system(size: size * 0.35))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.18, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
    }
}
