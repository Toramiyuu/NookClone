import SwiftUI
import EventKit

struct CalendarDayView: View {

    @ObservedObject private var manager = CalendarManager.shared

    private var dateHeader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private var hasAccess: Bool {
        switch manager.authorizationStatus {
        case .authorized: return true
        default:
            if #available(macOS 14.0, *) {
                return manager.authorizationStatus == .fullAccess
            }
            return false
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dateHeader)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))

            if hasAccess {
                eventList
            } else if manager.authorizationStatus == .notDetermined {
                permissionPrompt
            } else {
                deniedView
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var eventList: some View {
        Group {
            if manager.todayEvents.isEmpty {
                Text("No events today")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 4) {
                        ForEach(manager.todayEvents, id: \.eventIdentifier) { event in
                            CalendarEventView(event: event)
                        }
                    }
                }
                .frame(maxHeight: 100)
            }
        }
    }

    private var permissionPrompt: some View {
        Button {
            manager.checkAuthorizationAndFetch()
        } label: {
            Label("Grant Calendar Access", systemImage: "calendar.badge.plus")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .buttonStyle(.plain)
    }

    private var deniedView: some View {
        Text("Calendar access denied.\nEnable in System Settings → Privacy → Calendars.")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.4))
            .multilineTextAlignment(.leading)
    }
}
