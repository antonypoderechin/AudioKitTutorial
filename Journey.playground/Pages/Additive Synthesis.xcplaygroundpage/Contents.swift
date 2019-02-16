import AudioKitPlaygrounds
import AudioKit
import AudioKitUI
import PlaygroundSupport

func createAndStartOscillator(frequency: Double) -> AKOscillator {
    let oscillator = AKOscillator()
    oscillator.frequency = frequency
    return oscillator
}

let frequencies = (1...5).map { $0 * 261.63 }

let oscillators = frequencies.map {
    createAndStartOscillator(frequency: $0)
}
let mixer = AKMixer()
oscillators.forEach { $0.connect(to: mixer) }

let envelope = AKAmplitudeEnvelope(mixer)
envelope.attackDuration = 0.01
envelope.decayDuration = 0.1
envelope.sustainLevel = 0.1
envelope.releaseDuration = 0.3

AudioKit.output = envelope
let performance = AKPeriodicFunction(every: 0.5) {
    if (envelope.isStarted) {
        envelope.stop()
    } else {
        envelope.start()
    }
}
try AudioKit.start(withPeriodicFunctions: performance)
performance.start()
oscillators.forEach { $0.start() }

class LiveView: AKLiveViewController {
    override func viewDidLoad() {
        addTitle("Harmonics")

        oscillators.forEach {
            oscillator in
            let harmonicSlider = AKSlider(
                property: "\(oscillator.frequency) Hz",
                value: oscillator.amplitude
            ) { amplitude in
                oscillator.amplitude = amplitude
            }
            addView(harmonicSlider)
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

