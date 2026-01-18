//
//  SoundGenerator.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import AVFoundation
import Accelerate
import Combine

@MainActor
class SoundGenerator: ObservableObject {
    @Published var isEnabled: Bool = false
    
    var volume: Float = 0.5
    var sustainTime: Double = 0.3
    
    private let audioEngine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    private let sampleRate: Double = 44100
    private var activeNodeCount = 0
    private var isEngineSetup = false
    
    // Sound parameters matching Sound of Sorting
    private let minFrequency: Double = 120.0  // Hz
    private let maxFrequency: Double = 1212.0 // Hz
    
    init() {
        // Don't setup audio engine in init - do it lazily when needed
    }
    
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
    
    private func frequencyForValue(_ value: Int, maxValue: Int) -> Double {
        // Scale value from [1, maxValue] to [minFrequency, maxFrequency]
        let normalizedValue = Double(value) / Double(maxValue)
        return minFrequency + (normalizedValue * (maxFrequency - minFrequency))
    }
    
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

class Oscillator {
    private let frequency: Double
    private let duration: Double
    private let sampleRate: Double
    private let volumeScale: Float
    
    private var phase: Double = 0.0
    private var currentSample: Int = 0
    private let totalSamples: Int
    
    // ADSR envelope parameters (in samples)
    private let attackSamples: Int
    private let decaySamples: Int
    private let sustainLevel: Float = 0.7
    private let releaseSamples: Int
    
    var isFinished: Bool {
        currentSample >= totalSamples
    }
    
    init(frequency: Double, duration: Double, sustainTime: Double, sampleRate: Double, volumeScale: Float) {
        self.frequency = frequency
        self.duration = duration
        self.sampleRate = sampleRate
        self.volumeScale = volumeScale
        self.totalSamples = Int(duration * sampleRate)
        
        // ADSR envelope timing - sustain time affects the overall envelope
        let adjustedDuration = duration * (0.5 + sustainTime * 0.5) // Scale envelope with sustain
        self.attackSamples = Int(0.01 * sampleRate * adjustedDuration)  // 10ms attack (scaled)
        self.decaySamples = Int(0.02 * sampleRate * adjustedDuration)   // 20ms decay (scaled)
        self.releaseSamples = Int(0.05 * sampleRate * adjustedDuration) // 50ms release (scaled)
    }
    
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
    
    private func triangularWaveform(phase: Double) -> Double {
        // Triangular wave: rises from -1 to 1, then falls from 1 to -1
        if phase < 0.5 {
            return 4.0 * phase - 1.0
        } else {
            return 3.0 - 4.0 * phase
        }
    }
    
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
