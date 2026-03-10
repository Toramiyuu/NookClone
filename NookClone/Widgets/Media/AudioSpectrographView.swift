import SwiftUI
import AVFoundation
import Accelerate

/// Real-time FFT audio spectrum bars using AVAudioEngine.
class AudioSpectrograph: ObservableObject {

    @Published var magnitudes: [Float] = Array(repeating: 0, count: 20)

    private var engine: AVAudioEngine?
    private var isRunning = false
    private let barCount = 20
    private let bufferSize: AVAudioFrameCount = 1024

    func start() {
        guard !isRunning else { return }
        let engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else { startSimulation(); return }

        // Capture sample rate on the main thread before handing to audio thread
        let capturedSampleRate = Float(format.sampleRate)
        let capturedBarCount = barCount

        input.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            self?.processBuffer(buffer, sampleRate: capturedSampleRate, barCount: capturedBarCount)
        }

        do {
            try engine.start()
            self.engine = engine
            isRunning = true
        } catch {
            startSimulation()
        }
    }

    func stop() {
        engine?.inputNode.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        isRunning = false
        simulationTimer?.invalidate()
        simulationTimer = nil
        DispatchQueue.main.async { self.magnitudes = Array(repeating: 0, count: self.barCount) }
    }

    private func processBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Float, barCount: Int) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return }

        // Apply Hann window
        var windowedData = [Float](repeating: 0, count: frameCount)
        var window = [Float](repeating: 0, count: frameCount)
        vDSP_hann_window(&window, vDSP_Length(frameCount), Int32(vDSP_HANN_NORM))
        vDSP_vmul(channelData, 1, window, 1, &windowedData, 1, vDSP_Length(frameCount))

        // FFT setup
        let log2n = vDSP_Length(log2(Double(frameCount)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else { return }
        defer { vDSP_destroy_fftsetup(fftSetup) }

        var realp = [Float](repeating: 0, count: frameCount / 2)
        var imagp = [Float](repeating: 0, count: frameCount / 2)
        var splitComplex = DSPSplitComplex(realp: &realp, imagp: &imagp)

        windowedData.withUnsafeBytes { ptr in
            guard let base = ptr.bindMemory(to: DSPComplex.self).baseAddress else { return }
            vDSP_ctoz(base, 2, &splitComplex, 1, vDSP_Length(frameCount / 2))
        }
        vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

        var magnitudeBuffer = [Float](repeating: 0, count: frameCount / 2)
        vDSP_zvmags(&splitComplex, 1, &magnitudeBuffer, 1, vDSP_Length(frameCount / 2))

        // Map FFT bins to bars on a logarithmic frequency scale
        let binResolution = sampleRate / Float(frameCount)
        let minFreq: Float = 60
        let maxFreq: Float = 16000
        let binCount = frameCount / 2

        var bars = [Float](repeating: 0, count: barCount)
        for i in 0..<barCount {
            let freqLow  = minFreq * pow(maxFreq / minFreq, Float(i)     / Float(barCount))
            let freqHigh = minFreq * pow(maxFreq / minFreq, Float(i + 1) / Float(barCount))
            let binLow  = max(0, Int(freqLow  / binResolution))
            let binHigh = min(binCount - 1, Int(freqHigh / binResolution))

            var avg: Float = 0
            if binHigh >= binLow {
                magnitudeBuffer.withUnsafeBufferPointer { ptr in
                    vDSP_meanv(ptr.baseAddress! + binLow, 1, &avg, vDSP_Length(binHigh - binLow + 1))
                }
            }
            let db = 10 * log10(avg + 1e-10)
            bars[i] = max(0, min(1, (db + 60) / 60))
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.magnitudes = zip(self.magnitudes, bars).map { prev, new in prev * 0.3 + new * 0.7 }
        }
    }

    // MARK: - Simulation fallback (when mic unavailable/denied)

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
