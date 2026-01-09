import Foundation
import SwiftUI
import AVFoundation
import AudioToolbox
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class AlarmRingerManager: ObservableObject {
    static let shared = AlarmRingerManager()

    @Published var isRinging: Bool = false
    @Published var currentTitle: String = "Prayer Alarm"
    @Published private(set) var snoozeCount: Int = 0
    @Published var isProcessing: Bool = false

    private var soundTimer: Timer?
    fileprivate let maxSnoozes = 2
    private var currentBaseId: String?
    private var currentOccurrenceKey: String?
    private var currentChainKey: String? {
        get { UserDefaults.standard.string(forKey: "alarm.chainKey") }
        set { UserDefaults.standard.set(newValue, forKey: "alarm.chainKey") }
    }

    private init() {}
    
    deinit {
        soundTimer?.invalidate()
    }

    func triggerNow(title: String?, sourceId: String? = nil) {
        currentTitle = title ?? "Prayer Alarm"
        // Derive a base identifier for this occurrence (used to track snoozes)
        if let sid = sourceId { currentBaseId = baseIdPrefix(from: sid) } else { currentBaseId = "local" }
        // Maintain a chain key across snoozes for this alarm sequence
        if sourceId?.contains("inapp-snooze") == true, let chain = currentChainKey {
            currentOccurrenceKey = chain
        } else if let base = currentBaseId {
            let key = makeOccurrenceKey(baseId: base, date: Date())
            currentOccurrenceKey = key
            currentChainKey = key
        }
        if let key = currentOccurrenceKey {
            snoozeCount = loadSnoozeCount(for: key)
        } else {
            snoozeCount = 0
        }
        startRinging()
    }

    func snooze(minutes: Int) {
        guard canSnooze && !isProcessing else { return }
        
        // Simple immediate execution
        isProcessing = true
        incrementSnooze()
        stopRinging()
        
        // Schedule snooze immediately - no delays
        let date = Date().addingTimeInterval(TimeInterval(minutes * 60))
        NotificationManager.shared.scheduleOneOffReminder(
            id: "inapp-snooze-\(UUID().uuidString)",
            title: currentTitle,
            body: "Snoozed \(minutes)m",
            date: date
        )
        
        // Reset processing state immediately
        isProcessing = false
        
        // Haptic feedback last
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    func dismissAndStartPrayer(defaultMinutes: Int = 20) {
        print("🔥 [AlarmRinger] dismissAndStartPrayer called with \(defaultMinutes) minutes")
        print("🔥 [AlarmRinger] Current isProcessing state: \(isProcessing)")
        print("🔥 [AlarmRinger] Current isRinging state: \(isRinging)")
        
        guard !isProcessing else { 
            print("❌ [AlarmRinger] BLOCKED: Already processing, returning early")
            return 
        }
        
        print("✅ [AlarmRinger] Guard passed, starting execution...")
        
        // Simple, immediate execution - no delays or complex logic
        isProcessing = true
        print("🔄 [AlarmRinger] Set isProcessing = true")
        
        // Cancel followups and stop ringing immediately
        if let base = currentBaseId {
            print("🗑️ [AlarmRinger] Canceling followups for baseId: \(base)")
            NotificationManager.shared.cancelFollowupsPublic(baseId: base)
        }
        
        print("🔇 [AlarmRinger] Stopping ringing...")
        stopRinging()
        print("🧹 [AlarmRinger] Clearing chain...")
        clearChain()
        
        // Bridge to intent-style flow; app views can listen for this and navigate accordingly.
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "intent.startPrayer.timestamp")
        UserDefaults.standard.set(defaultMinutes, forKey: "intent.startPrayer.minutes")
        NotificationCenter.default.post(name: .intentStartPrayer, object: nil, userInfo: ["minutes": defaultMinutes])
        
        // Reset processing state immediately
        isProcessing = false
        print("✅ [AlarmRinger] Set isProcessing = false, execution complete!")
        
        // Haptic feedback last to avoid any potential blocking
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        print("📳 [AlarmRinger] Haptic feedback sent")
        #endif
    }

    func rejectNow() {
        guard !isProcessing else { return }
        
        // Simple immediate execution
        isProcessing = true
        
        if let base = currentBaseId {
            NotificationManager.shared.cancelFollowupsPublic(baseId: base)
        }
        
        stopRinging()
        clearChain()
        
        // Reset processing state immediately
        isProcessing = false
        
        // Haptic feedback last
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }

    private func startRinging() {
        isRinging = true
        // Kick off repeating system sound + haptic every ~2s as a fallback when foreground
        playTick()
        soundTimer?.invalidate()
        soundTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.playTick()
        }
    }

    private func stopRinging() {
        withAnimation(.easeInOut(duration: 0.15)) {
            isRinging = false
        }
        soundTimer?.invalidate()
        soundTimer = nil
    }

    nonisolated private func playTick() {
        // System sound id 1005 (new mail) as placeholder; respects ringer/volume
        AudioServicesPlaySystemSound(1005)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    private var canSnooze: Bool { snoozeCount < maxSnoozes }
    private func incrementSnooze() {
        snoozeCount = min(maxSnoozes, snoozeCount + 1)
        if let key = currentOccurrenceKey { saveSnoozeCount(snoozeCount, for: key) }
    }

    private func makeOccurrenceKey(baseId: String?, date: Date) -> String {
        let base = baseId ?? "local"
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmm"
        return "\(base)_\(f.string(from: date))"
    }

    private func loadSnoozeCount(for key: String) -> Int {
        UserDefaults.standard.integer(forKey: "alarm.snooze.\(key)")
    }
    private func saveSnoozeCount(_ count: Int, for key: String) {
        UserDefaults.standard.set(count, forKey: "alarm.snooze.\(key)")
    }

    private func clearChain() {
        if let key = currentChainKey {
            UserDefaults.standard.removeObject(forKey: "alarm.snooze.\(key)")
        }
        currentChainKey = nil
    }

    private func baseIdPrefix(from identifier: String) -> String {
        if let range = identifier.range(of: "-w") { return String(identifier[..<range.lowerBound]) }
        if let range = identifier.range(of: "-fup-") { return String(identifier[..<range.lowerBound]) }
        if let range = identifier.range(of: "-snooze") { return String(identifier[..<range.lowerBound]) }
        return identifier
    }
}

// MARK: - Overlay view for in-app ringing
struct AlarmRingOverlay: View {
    @ObservedObject private var ringer = AlarmRingerManager.shared

    private var defaultSessionMinutes: Int {
        let value = UserDefaults.standard.integer(forKey: "settings.defaultSessionMinutes")
        return value > 0 ? value : 20
    }

    var body: some View {
        Group {
            if ringer.isRinging {
                ZStack {
                    Color.black.opacity(0.65).ignoresSafeArea()

                    VStack(spacing: 16) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(Color.altarSoftGold)

                        Text(ringer.currentTitle)
                            .font(.title2.weight(.bold))

                        Text("It's time to pray.")
                            .foregroundStyle(.secondary)

                        VStack(spacing: 12) {
                            Button {
                                ringer.dismissAndStartPrayer(defaultMinutes: defaultSessionMinutes)
                            } label: {
                                HStack(spacing: 10) {
                                    if ringer.isProcessing {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    } else {
                                        Image(systemName: "play.fill")
                                    }
                                    Text(ringer.isProcessing ? "Starting…" : "Start Prayer")
                                        .font(.headline.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.altarRed)
                            .disabled(ringer.isProcessing)

                            if ringer.snoozeCount < ringer.maxSnoozes {
                                Button {
                                    ringer.snooze(minutes: 5)
                                } label: {
                                    HStack {
                                        Image(systemName: "zzz")
                                        Text("Snooze 5 min")
                                        Spacer()
                                        Text("\(ringer.maxSnoozes - ringer.snoozeCount) left")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                }
                                .buttonStyle(.bordered)
                                .disabled(ringer.isProcessing)
                            }

                            Button(role: .destructive) {
                                ringer.rejectNow()
                            } label: {
                                Text("Dismiss")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.bordered)
                            .disabled(ringer.isProcessing)
                        }
                    }
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.altarCardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
    }
}

extension View {
    func withAlarmRinger() -> some View { self.overlay(AlarmRingOverlay()) }
}
