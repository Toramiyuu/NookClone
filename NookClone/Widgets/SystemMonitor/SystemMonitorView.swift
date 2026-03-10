import SwiftUI

struct SystemMonitorView: View {

    @ObservedObject private var monitor = SystemMonitorManager.shared
    @ObservedObject private var settings = SystemMonitorSettings.shared

    var body: some View {
        HStack(spacing: 16) {
            if settings.showCPU {
                GaugeColumn(
                    label: "CPU",
                    value: monitor.cpuUsage,
                    text: String(format: "%.0f%%", monitor.cpuUsage * 100),
                    color: cpuColor
                )
            }
            if settings.showMemory {
                GaugeColumn(
                    label: "MEM",
                    value: monitor.memoryPressure,
                    text: String(format: "%.1fG", monitor.memoryUsed),
                    color: .cyan
                )
            }
            if settings.showBattery && monitor.hasBattery {
                GaugeColumn(
                    label: monitor.isCharging ? "CHG" : "BAT",
                    value: Double(monitor.batteryPercent) / 100.0,
                    text: "\(monitor.batteryPercent)%",
                    color: batteryColor
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var cpuColor: Color {
        switch monitor.cpuUsage {
        case ..<0.5: return .green
        case ..<0.8: return .yellow
        default:     return .red
        }
    }

    private var batteryColor: Color {
        if monitor.isCharging { return .green }
        switch monitor.batteryPercent {
        case 20...: return .white
        default:    return .red
        }
    }
}

private struct GaugeColumn: View {
    let label: String
    let value: Double   // 0-1
    let text: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.12), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: CGFloat(min(value, 1)))
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: value)
                Text(text)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}
