import SwiftUI

/// Animated spectrum bar visualization for the media widget.
class AudioSpectrograph: ObservableObject {

    @Published var magnitudes: [Float] = Array(repeating: 0, count: 20)

    private var isRunning = false
    private let barCount = 20

    func start() {
        guard !isRunning else { return }
        // Use animated simulation rather than a real microphone tap.
        // AVAudioEngine.inputNode taps on macOS create an audio loopback that
        // routes mic input into the speaker output, audibly changing playback.
        isRunning = true
        startSimulation()
    }

    func stop() {
        isRunning = false
        simulationTimer?.invalidate()
        simulationTimer = nil
        DispatchQueue.main.async { self.magnitudes = Array(repeating: 0, count: self.barCount) }
    }

    // MARK: - Simulation

    private var simulationTimer: Timer?
    private var simulationPhase: Float = 0

    private func startSimulation() {
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.tickSimulation()
        }
    }

    private func tickSimulation() {
        simulationPhase += 0.15
        let bars = (0..<barCount).map { i -> Float in
            let base = sin(simulationPhase + Float(i) * 0.5) * 0.3 + 0.35
            let noise = Float.random(in: -0.08...0.08)
            return max(0.05, min(1, base + noise))
        }
        DispatchQueue.main.async { self.magnitudes = bars }
    }
}

/// Animated bar-chart spectrum visualization.
struct AudioSpectrographView: View {

    @ObservedObject var spectrograph: AudioSpectrograph
    var isActive: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(spectrograph.magnitudes.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor(for: spectrograph.magnitudes[i]))
                    .frame(width: 3, height: max(4, CGFloat(spectrograph.magnitudes[i]) * 40))
                    .animation(.easeOut(duration: 0.05), value: spectrograph.magnitudes[i])
            }
        }
        .frame(height: 40, alignment: .bottom)
        .onChange(of: isActive) { _, active in
            if active { spectrograph.start() } else { spectrograph.stop() }
        }
        .onAppear { if isActive { spectrograph.start() } }
        .onDisappear { spectrograph.stop() }
    }

    private func barColor(for magnitude: Float) -> Color {
        let hue = 0.6 - Double(magnitude) * 0.3
        return Color(hue: hue, saturation: 0.8, brightness: 0.9)
    }
}
