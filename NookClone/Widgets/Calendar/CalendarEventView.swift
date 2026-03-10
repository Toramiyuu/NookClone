import SwiftUI
import EventKit

struct CalendarEventView: View {

    let event: EKEvent

    private var timeString: String {
        if event.isAllDay { return "All day" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let start = formatter.string(from: event.startDate)
        let end = formatter.string(from: event.endDate)
        return "\(start) – \(end)"
    }

    private var calendarColor: Color {
        if let cgColor = event.calendar.cgColor {
            return Color(cgColor: cgColor)
        }
        return Color.accentColor
    }

    var body: some View {
        Button {
            CalendarManager.shared.openEvent(event)
        } label: {
            HStack(spacing: 8) {
                // Color dot
                Circle()
                    .fill(calendarColor)
                    .frame(width: 7, height: 7)

                VStack(alignment: .leading, spacing: 1) {
                    Text(event.title ?? "Untitled")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(timeString)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))

                    if let location = event.location, !location.isEmpty {
                        Text(location)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }
}
