import SwiftUI

/// Sliders to fine-tune notch panel position for non-standard screens.
struct NotchFineTuneView: View {
    @ObservedObject private var settings = GeneralSettings.shared

    var body: some View {
        VStack(spacing: 12) {
            LabeledContent("Width offset") {
                HStack {
                    Slider(value: $settings.notchWidthOffset, in: -50...50, step: 1)
                    Text("\(Int(settings.notchWidthOffset))pt")
                        .monospacedDigit()
                        .frame(width: 40)
                }
            }
            LabeledContent("Height offset") {
                HStack {
                    Slider(value: $settings.notchHeightOffset, in: -20...20, step: 1)
                    Text("\(Int(settings.notchHeightOffset))pt")
                        .monospacedDigit()
                        .frame(width: 40)
                }
            }
            Button("Reset") {
                settings.notchWidthOffset = 0
                settings.notchHeightOffset = 0
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
