import SwiftUI
import EventKit

struct CalendarWidgetSettingsView: View {
    @ObservedObject private var manager = CalendarManager.shared

    var body: some View {
        Form {
            Section("Display") {
                Toggle("Show all-day events", isOn: $manager.showAllDayEvents)
            }
            Section("Calendars") {
                ForEach(manager.allCalendars, id: \.calendarIdentifier) { cal in
                    Toggle(
                        isOn: Binding(
                            get: { !manager.calendarFilter.contains(cal.calendarIdentifier) },
                            set: { show in
                                if show {
                                    manager.calendarFilter.remove(cal.calendarIdentifier)
                                } else {
                                    manager.calendarFilter.insert(cal.calendarIdentifier)
                                }
                            }
                        )
                    ) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(cgColor: cal.cgColor))
                                .frame(width: 10, height: 10)
                            Text(cal.title)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
