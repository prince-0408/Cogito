import Foundation
import CoreHaptics
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    
    private init() {
        prepareHaptics()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Restart engine if it stops or gets interrupted:
            engine?.resetHandler = { [weak self] in
                print("Haptic Engine Reset")
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart Haptic Engine: \(error)")
                }
            }
            
            engine?.stoppedHandler = { reason in
                print("Haptic Engine Stopped: \(reason)")
            }
        } catch {
            print("Failed to initialize Haptic Engine: \(error)")
        }
    }
    
    // 1. Task Completed Double Click (High sharpness click followed by softer click)
    func playCompletedTaskHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine = engine else {
            // Fallback for devices without CoreHaptics support
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            return
        }
        
        do {
            let firstTick = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.85)
                ],
                relativeTime: 0.0
            )
            
            let secondTick = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.35)
                ],
                relativeTime: 0.08
            )
            
            let pattern = try CHHapticPattern(events: [firstTick, secondTick], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play task completed haptic: \(error)")
        }
    }
    
    // 2. Confetti Sparkles Sequence (18 scattered lightweight transient clicks over 1.5s)
    func playConfettiSparkles() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine = engine else {
            // Fallback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return
        }
        
        var events: [CHHapticEvent] = []
        for _ in 0..<18 {
            let relativeTime = Double.random(in: 0.0...1.5)
            let intensity = Float.random(in: 0.22...0.55)
            let sharpness = Float.random(in: 0.5...0.9)
            
            let sparkle = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: relativeTime
            )
            events.append(sparkle)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play confetti sparkle haptic: \(error)")
        }
    }
    
    // 3. AI Cognitive Hum Continuous Surge Pattern (Modulated swelling hum)
    private var activeHumPlayer: CHHapticAdvancedPatternPlayer?
    
    func startAICognitiveHum() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine = engine else { return }
        
        do {
            let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.15)
            let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            
            let humEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensityParameter, sharpnessParameter],
                relativeTime: 0.0,
                duration: 4.0
            )
            
            // Swelling sine curves for dynamic intensity control over time
            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: 0.15),
                    .init(relativeTime: 1.0, value: 0.65),
                    .init(relativeTime: 2.0, value: 0.35),
                    .init(relativeTime: 3.0, value: 0.75),
                    .init(relativeTime: 4.0, value: 0.0)
                ],
                relativeTime: 0.0
            )
            
            let pattern = try CHHapticPattern(events: [humEvent], parameterCurves: [intensityCurve])
            activeHumPlayer = try engine.makeAdvancedPlayer(with: pattern)
            try activeHumPlayer?.start(atTime: 0)
        } catch {
            print("Failed to play continuous cognitive hum: \(error)")
        }
    }
    
    func stopAICognitiveHum() {
        do {
            try activeHumPlayer?.stop(atTime: 0)
        } catch {
            print("Failed to stop hum player: \(error)")
        }
    }
}
