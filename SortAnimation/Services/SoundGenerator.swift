//
//  SoundGenerator.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import AVFoundation
import Accelerate
import Combine

/// Generates audio tones for sorting algorithm visualization.
///
/// This class uses `AVAudioEngine` to generate real-time audio feedback matching
/// the visual sorting animations. Frequencies are mapped to element values, creating
/// an audible representation of the sorting process inspired by "The Sound of Sorting".
///
/// ## Features
/// - Triangular wave oscillators for smooth, musical tones
/// - ADSR envelope (Attack, Decay, Sustain, Release) for natural sound
/// - Thread-safe audio rendering
/// - Automatic volume adjustment for multiple simultaneous tones
/// - Frequency range: 120 Hz - 1212 Hz
///
/// ## Usage
/// ```swift
/// let generator = SoundGenerator()
/// generator.isEnabled = true
/// generator.volume = 0.5
/// generator.playComparison(value1: 10, value2: 20, maxValue: 100)
/// ```
@MainActor
class SoundGenerator: ObservableObject {
    /// Whether sound generation is currently enabled
    @Published var isEnabled: Bool = false
    
    /// Master volume level (0.0 to 1.0)
    var volume: Float = 0.5
    
    /// Sustain time affects the ADSR envelope shape (0.0 to 1.0)
    var sustainTime: Double = 0.3
    
    private let audioEngine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    private let sampleRate: Double = 44100
    private var activeNodeCount = 0
    private var isEngineSetup = false
    
    /// Sound parameters matching Sound of Sorting frequency range
    private let minFrequency: Double = 120.0  // Hz (low note)
    private let maxFrequency: Double = 1212.0 // Hz (high note)
    
    init() {
        // Audio engine is setup lazily when first needed for better performance
    }
    
    /// Sets up the audio engine and mixer node.
    ///
    /// This method is called automatically on first use. It attaches the mixer to the engine
    /// and starts audio processing.
    ///
    /// - Note: This method is idempotent - calling it multiple times has no effect after initial setup.
    private func setupAudioEngine() {
        guard !isEngineSetup else { return }
        isEngineSetup = true
        
        audioEngine.attach(mixer)
        audioEngine.connect(mixer, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
            isEngineSetup = false
        }
    }
    
    /// Plays audio tones representing a comparison between two values.
    ///
    /// This method generates two simultaneous tones with frequencies mapped to the compared values,
    /// creating an audible representation of the comparison operation.
    ///
    /// - Parameters:
    ///   - value1: The first value being compared
    ///   - value2: The second value being compared
    ///   - maxValue: The maximum possible value (used for frequency scaling)
    ///   - duration: Duration of the tone in seconds (default: 0.05)
    ///
    /// - Note: No sound is played if ``isEnabled`` is `false`.
    func playComparison(value1: Int, value2: Int, maxValue: Int, duration: Double = 0.05) {
        guard isEnabled else { return }
        
        // Setup audio engine on first use
        setupAudioEngine()
        
        // Calculate frequencies from values (scaled to 120-1212 Hz range)
        let freq1 = frequencyForValue(value1, maxValue: maxValue)
        let freq2 = frequencyForValue(value2, maxValue: maxValue)
        
        // Play both frequencies
        playTone(frequency: freq1, duration: duration)
        playTone(frequency: freq2, duration: duration)
    }
    
    /// Converts an integer value to an audio frequency.
    ///
    /// Maps values linearly from [1, maxValue] to [120 Hz, 1212 Hz], matching
    /// the frequency range used in "The Sound of Sorting".
    ///
    /// - Parameters:
    ///   - value: The value to convert (1 to maxValue)
    ///   - maxValue: The maximum value in the dataset
    /// - Returns: The corresponding frequency in Hertz
    private func frequencyForValue(_ value: Int, maxValue: Int) -> Double {
        // Scale value from [1, maxValue] to [minFrequency, maxFrequency]
        let normalizedValue = Double(value) / Double(maxValue)
        return minFrequency + (normalizedValue * (maxFrequency - minFrequency))
    }
    
    /// Plays a single tone at the specified frequency and duration.
    ///
    /// Creates an `AVAudioSourceNode` with a triangular wave oscillator and ADSR envelope.
    /// The node is automatically detached after the tone completes.
    ///
    /// - Parameters:
    ///   - frequency: The tone frequency in Hertz
    ///   - duration: Duration of the tone in seconds
    ///
    /// - Important: This method uses real-time audio rendering. The render callback is
    ///              thread-safe and avoids Swift collection access for optimal performance.
    private func playTone(frequency: Double, duration: Double) {
        activeNodeCount += 1
        
        // Create oscillator with current settings
        let oscillator = Oscillator(
            frequency: frequency,
            duration: duration,
            sustainTime: sustainTime,
            sampleRate: sampleRate,
            volumeScale: volumeScaleForActiveOscillators() * volume
        )
        
        // Create audio source node with captured oscillator (thread-safe)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                let sample = oscillator.nextSample()
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = sample
                }
            }
            
            return noErr
        }
        
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: mixer, format: format)
        
        // Detach node after duration
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration * 1.5))
            detachNode(sourceNode)
        }
    }
    
    private func volumeScaleForActiveOscillators() -> Float {
        // Scale volume down based on number of active nodes
        let count = max(1, activeNodeCount)
        return 1.0 / Float(sqrt(Double(count)))
    }
    
    private func detachNode(_ node: AVAudioNode) {
        audioEngine.disconnectNodeOutput(node)
        audioEngine.detach(node)
        activeNodeCount = max(0, activeNodeCount - 1)
    }
}

// MARK: - Oscillator

/// A triangular wave oscillator with ADSR envelope for audio generation.
///
/// This class generates audio samples for a single tone with:
/// - **Triangular waveform**: Creates a smooth, musical sound
/// - **ADSR envelope**: Attack, Decay, Sustain, Release for natural sound shaping
/// - **Thread-safe rendering**: Safe to call from audio render thread
///
/// The oscillator automatically tracks its playback position and signals completion
/// when the duration expires.
class Oscillator {
    private let frequency: Double
    private let duration: Double
    private let sampleRate: Double
    private let volumeScale: Float
    
    private var phase: Double = 0.0
    private var currentSample: Int = 0
    private let totalSamples: Int
    
    /// ADSR envelope parameters (in samples)
    private let attackSamples: Int
    private let decaySamples: Int
    private let sustainLevel: Float = 0.7
    private let releaseSamples: Int
    
    /// Whether this oscillator has finished playing
    var isFinished: Bool {
        currentSample >= totalSamples
    }
    
    /// Creates a new oscillator with the specified parameters.
    ///
    /// - Parameters:
    ///   - frequency: Tone frequency in Hertz
    ///   - duration: Total duration in seconds
    ///   - sustainTime: Controls envelope shape (0.0-1.0, longer sustain = fuller tone)
    ///   - sampleRate: Audio sample rate (typically 44100 Hz)
    ///   - volumeScale: Volume multiplier (adjusted for multiple simultaneous tones)
    init(frequency: Double, duration: Double, sustainTime: Double, sampleRate: Double, volumeScale: Float) {
        self.frequency = frequency
        self.duration = duration
        self.sampleRate = sampleRate
        self.volumeScale = volumeScale
        self.totalSamples = Int(duration * sampleRate)
        
        /// ADSR envelope timing - sustain time scales the envelope duration
        let adjustedDuration = duration * (0.5 + sustainTime * 0.5)
        self.attackSamples = Int(0.01 * sampleRate * adjustedDuration)  // 10ms attack
        self.decaySamples = Int(0.02 * sampleRate * adjustedDuration)   // 20ms decay
        self.releaseSamples = Int(0.05 * sampleRate * adjustedDuration) // 50ms release
    }
    
    /// Generates the next audio sample.
    ///
    /// Combines triangular waveform generation with ADSR envelope application.
    ///
    /// - Returns: The next audio sample value, or 0.0 if playback is complete
    ///
    /// - Important: This method is thread-safe and optimized for real-time audio rendering.
    func nextSample() -> Float {
        guard currentSample < totalSamples else {
            return 0.0
        }
        
        // Generate triangular wave
        let triangularWave = triangularWaveform(phase: phase)
        
        // Apply ADSR envelope
        let envelope = adsrEnvelope(sampleIndex: currentSample)
        
        // Combine waveform and envelope
        let sample = Float(triangularWave) * envelope * volumeScale * 0.3 // Master volume
        
        // Advance phase for next sample
        phase += frequency / sampleRate
        if phase >= 1.0 {
            phase -= 1.0
        }
        
        currentSample += 1
        
        return sample
    }
    
    /// Generates a triangular waveform value for the given phase.
    ///
    /// The triangular wave rises linearly from -1 to 1 in the first half,
    /// then falls linearly from 1 to -1 in the second half.
    ///
    /// - Parameter phase: Current phase (0.0 to 1.0)
    /// - Returns: Waveform amplitude (-1.0 to 1.0)
    private func triangularWaveform(phase: Double) -> Double {
        // Triangular wave: rises from -1 to 1, then falls from 1 to -1
        if phase < 0.5 {
            return 4.0 * phase - 1.0
        } else {
            return 3.0 - 4.0 * phase
        }
    }
    
    /// Calculates the ADSR envelope value for a given sample index.
    ///
    /// The envelope consists of four phases:
    /// - **Attack**: Ramps from 0 to 1
    /// - **Decay**: Falls from 1 to sustain level
    /// - **Sustain**: Holds at sustain level
    /// - **Release**: Falls from sustain level to 0
    ///
    /// - Parameter sampleIndex: Current sample position
    /// - Returns: Envelope multiplier (0.0 to 1.0)
    private func adsrEnvelope(sampleIndex: Int) -> Float {
        let sample = Float(sampleIndex)
        
        // Attack phase
        if sampleIndex < attackSamples {
            return sample / Float(attackSamples)
        }
        
        // Decay phase
        if sampleIndex < attackSamples + decaySamples {
            let decayProgress = Float(sampleIndex - attackSamples) / Float(decaySamples)
            return 1.0 - (decayProgress * (1.0 - sustainLevel))
        }
        
        // Sustain phase
        if sampleIndex < totalSamples - releaseSamples {
            return sustainLevel
        }
        
        // Release phase
        let releaseProgress = Float(totalSamples - sampleIndex) / Float(releaseSamples)
        return sustainLevel * releaseProgress
    }
}
