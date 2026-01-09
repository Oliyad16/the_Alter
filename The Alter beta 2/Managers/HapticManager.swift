import Foundation
#if canImport(UIKit)
import UIKit
#endif
import CoreHaptics
import Combine
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Haptic Feedback Types
enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case soft
    case rigid
    case success
    case warning
    case error
    case achievement
    case celebration
    case flame
    case prayer
    case milestone
}

// MARK: - Haptic Manager
@MainActor
final class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    @Published var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: "hapticsEnabled")
        }
    }
    
    private var hapticEngine: CHHapticEngine?
    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    private init() {
        self.isHapticsEnabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
        setupHapticEngine()
    }
    
    private func setupHapticEngine() {
        guard supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            // Handle engine stopped
            hapticEngine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
            
            // Handle engine reset
            hapticEngine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    // MARK: - Public Interface
    func trigger(_ type: HapticFeedbackType) {
        guard isHapticsEnabled else { return }
        
        #if canImport(UIKit)
        switch type {
        case .light: impactFeedback(.light)
        case .medium: impactFeedback(.medium)
        case .heavy: impactFeedback(.heavy)
        case .soft: impactFeedback(.soft)
        case .rigid: impactFeedback(.rigid)
        case .success: notificationFeedback(.success)
        case .warning: notificationFeedback(.warning)
        case .error: notificationFeedback(.error)
        case .achievement: playAchievementHaptic()
        case .celebration: playCelebrationHaptic()
        case .flame: playFlameHaptic()
        case .prayer: playPrayerHaptic()
        case .milestone: playMilestoneHaptic()
        }
        #else
        switch type {
        case .light: playTransient(intensity: 0.25, sharpness: 0.3)
        case .medium: playTransient(intensity: 0.5, sharpness: 0.5)
        case .heavy: playTransient(intensity: 0.9, sharpness: 0.8)
        case .soft: playTransient(intensity: 0.2, sharpness: 0.1)
        case .rigid: playTransient(intensity: 0.6, sharpness: 1.0)
        case .success: playTransient(intensity: 0.6, sharpness: 0.6)
        case .warning: playTransient(intensity: 0.7, sharpness: 0.4)
        case .error: playTransient(intensity: 0.9, sharpness: 0.2)
        case .achievement: playAchievementHaptic()
        case .celebration: playCelebrationHaptic()
        case .flame: playFlameHaptic()
        case .prayer: playPrayerHaptic()
        case .milestone: playMilestoneHaptic()
        }
        #endif
    }
    
    // MARK: - Basic Haptic Feedback
    #if canImport(UIKit)
    private func impactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func notificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    #endif

    private func playTransient(intensity: Float, sharpness: Float) {
        guard supportsHaptics, let engine = hapticEngine else { return }
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // If CoreHaptics fails, silently ignore to avoid impacting UX.
        }
    }
    
    // MARK: - Custom Haptic Patterns
    private func playAchievementHaptic() {
        guard hapticEngine != nil else {
            #if canImport(UIKit)
            impactFeedback(.heavy)
            #else
            playTransient(intensity: 0.9, sharpness: 0.8)
            #endif
            return
        }
        
        let pattern = createAchievementPattern()
        playPattern(pattern)
    }
    
    private func playCelebrationHaptic() {
        guard hapticEngine != nil else {
            #if canImport(UIKit)
            impactFeedback(.medium)
            #else
            playTransient(intensity: 0.6, sharpness: 0.6)
            #endif
            return
        }
        
        let pattern = createCelebrationPattern()
        playPattern(pattern)
    }
    
    private func playFlameHaptic() {
        guard hapticEngine != nil else {
            #if canImport(UIKit)
            impactFeedback(.light)
            #else
            playTransient(intensity: 0.25, sharpness: 0.3)
            #endif
            return
        }
        
        let pattern = createFlamePattern()
        playPattern(pattern)
    }
    
    private func playPrayerHaptic() {
        guard hapticEngine != nil else {
            #if canImport(UIKit)
            impactFeedback(.soft)
            #else
            playTransient(intensity: 0.2, sharpness: 0.1)
            #endif
            return
        }
        
        let pattern = createPrayerPattern()
        playPattern(pattern)
    }
    
    private func playMilestoneHaptic() {
        guard hapticEngine != nil else {
            #if canImport(UIKit)
            impactFeedback(.heavy)
            #else
            playTransient(intensity: 0.9, sharpness: 0.8)
            #endif
            return
        }
        
        let pattern = createMilestonePattern()
        playPattern(pattern)
    }
    
    // MARK: - Haptic Pattern Creation
    private func createAchievementPattern() -> CHHapticPattern? {
        let events = [
            // Initial impact
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                ],
                relativeTime: 0
            ),
            // Echo effect
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
                ],
                relativeTime: 0.1
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
                ],
                relativeTime: 0.2
            )
        ]
        
        do {
            return try CHHapticPattern(events: events, parameters: [])
        } catch {
            print("Failed to create achievement pattern: \(error)")
            return nil
        }
    }
    
    private func createCelebrationPattern() -> CHHapticPattern? {
        var events: [CHHapticEvent] = []
        
        // Create a burst of events
        for i in 0..<5 {
            let intensity = 1.0 - (Double(i) * 0.15)
            let sharpness = 0.8 - (Double(i) * 0.1)
            
            events.append(
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness)),
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
                    ],
                    relativeTime: Double(i) * 0.08
                )
            )
        }
        
        do {
            return try CHHapticPattern(events: events, parameters: [])
        } catch {
            print("Failed to create celebration pattern: \(error)")
            return nil
        }
    }
    
    private func createFlamePattern() -> CHHapticPattern? {
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
                ],
                relativeTime: 0,
                duration: 0.3
            )
        ]
        
        let dynamicParameters = [
            CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.5),
                    CHHapticParameterCurve.ControlPoint(relativeTime: 0.15, value: 0.8),
                    CHHapticParameterCurve.ControlPoint(relativeTime: 0.3, value: 0.3)
                ],
                relativeTime: 0
            )
        ]
        
        do {
            return try CHHapticPattern(events: events, parameterCurves: dynamicParameters)
        } catch {
            print("Failed to create flame pattern: \(error)")
            return nil
        }
    }
    
    private func createPrayerPattern() -> CHHapticPattern? {
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
                ],
                relativeTime: 0,
                duration: 0.5
            )
        ]
        
        do {
            return try CHHapticPattern(events: events, parameters: [])
        } catch {
            print("Failed to create prayer pattern: \(error)")
            return nil
        }
    }
    
    private func createMilestonePattern() -> CHHapticPattern? {
        let events = [
            // Strong initial impact
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                ],
                relativeTime: 0
            ),
            // Sustained rumble
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
                ],
                relativeTime: 0.1,
                duration: 0.4
            ),
            // Final impact
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
                ],
                relativeTime: 0.5
            )
        ]
        
        do {
            return try CHHapticPattern(events: events, parameters: [])
        } catch {
            print("Failed to create milestone pattern: \(error)")
            return nil
        }
    }
    
    // MARK: - Pattern Playback
    private func playPattern(_ pattern: CHHapticPattern?) {
        guard let pattern = pattern,
              let engine = hapticEngine else { return }
        
        do {
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
    
    // MARK: - Convenience Methods
    func buttonTap() {
        trigger(.light)
    }
    
    func selectionChanged() {
        trigger(.soft)
    }
    
    func achievementUnlocked() {
        trigger(.achievement)
    }
    
    func milestoneReached() {
        trigger(.milestone)
    }
    
    func prayerStarted() {
        trigger(.prayer)
    }
    
    func flameInteraction() {
        trigger(.flame)
    }
    
    func celebrateSuccess() {
        trigger(.celebration)
    }
    
    func errorOccurred() {
        trigger(.error)
    }
    
    func warningNotification() {
        trigger(.warning)
    }
    
    func successNotification() {
        trigger(.success)
    }

    // MARK: - Settings Support
    var isEnabled: Bool {
        get { isHapticsEnabled }
    }

    func setEnabled(_ enabled: Bool) {
        isHapticsEnabled = enabled
    }

    #if canImport(UIKit)
    // Convenience for impact with style parameter
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }
        impactFeedback(style)
    }
    #endif
}

// MARK: - SwiftUI Integration
#if canImport(SwiftUI)
extension View {
    func onHapticTap(_ type: HapticFeedbackType = .light) -> some View {
        self.onTapGesture {
            HapticManager.shared.trigger(type)
        }
    }
    
    func onHapticLongPress(_ type: HapticFeedbackType = .medium) -> some View {
        self.onLongPressGesture {
            HapticManager.shared.trigger(type)
        }
    }
}
#endif
