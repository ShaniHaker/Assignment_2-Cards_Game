
//  GameAudioController.swift
//  Assigment_2_IOS


import AVFoundation
import AudioToolbox

final class GameAudioController {
    static let shared = GameAudioController()

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var musicBuffer: AVAudioPCMBuffer?
    private var isPrepared = false

    private init() {}

    // Start background music.
    func startMusic() {
        prepareIfNeeded()

        if !engine.isRunning {
            try? engine.start()
        }

        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    // Pause background music.
    func pauseMusic() {
        playerNode.pause()
    }

    // Stop background music and reset the loop.
    func stopMusic() {
        playerNode.stop()
        engine.stop()
        scheduleLoopingMusic()
    }

    // Play a short card sound.
    func playCardSound() {
        AudioServicesPlaySystemSound(1104)
    }

    // Play a sound when the game ends.
    func playGameFinishedSound() {
        AudioServicesPlaySystemSound(1025)
    }

    // Prepare the audio engine only once.
    private func prepareIfNeeded() {
        guard !isPrepared else { return }

        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        musicBuffer = makeMusicBuffer(format: format)
        scheduleLoopingMusic()
        isPrepared = true
    }

    // Queue the generated music buffer in a loop.
    private func scheduleLoopingMusic() {
        guard let musicBuffer else { return }
        playerNode.scheduleBuffer(musicBuffer, at: nil, options: .loops)
    }

    // Create a simple generated melody for the background music.
    private func makeMusicBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sampleRate = format.sampleRate
        let duration = 2.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        guard let samples = buffer.floatChannelData?[0] else {
            return buffer
        }

        let notes = [261.63, 329.63, 392.00, 329.63]
        let framesPerNote = Int(frameCount) / notes.count

        for frame in 0..<Int(frameCount) {
            let noteIndex = min(frame / framesPerNote, notes.count - 1)
            let frequency = notes[noteIndex]
            let time = Double(frame) / sampleRate
            samples[frame] = Float(sin(2.0 * Double.pi * frequency * time) * 0.08)
        }

        return buffer
    }
}
