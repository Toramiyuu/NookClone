import SwiftUI

struct ShelfTrayView: View {

    let items: [DroppedItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    ShelfItemView(item: item)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct ShelfItemView: View {

    let item: DroppedItem
    @State private var showingActions = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                if let icon = item.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 36, height: 36)
                } else {
                    Image(systemName: item.url != nil ? "doc" : "text.bubble")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 36, height: 36)
                }

                // Remove button
                Button {
                    withAnimation { DropAreaStore.shared.remove(item.id) }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                        .background(Circle().fill(.black))
                }
                .buttonStyle(.plain)
                .offset(x: 6, y: -6)
            }

            Text(item.displayName)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
                .frame(width: 50)
        }
        .onTapGesture { showingActions = true }
        .popover(isPresented: $showingActions) {
            DropAreaTargetView(item: item)
                .padding(12)
        }
    }
}
