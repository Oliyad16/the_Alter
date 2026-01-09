import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Meeting Place Main (with Timer)
struct MeetingPlaceView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var isInPrayer = false
    @State private var currentSession: PrayerSession?
    @State private var startTime: Date?
    @State private var duration: TimeInterval = 20 * 60
    @State private var remaining: TimeInterval = 20 * 60
    @State private var isTimerRunning = false
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.altarBlack.ignoresSafeArea()
                if isInPrayer {
                    ActivePrayerView(
                        session: currentSession,
                        startTime: startTime ?? Date(),
                        duration: duration,
                        remaining: $remaining,
                        isTimerRunning: $isTimerRunning,
                        onEnd: { endPrayerSession() }
                    )
                } else {
                    PrePrayerView(
                        duration: $duration,
                        onBegin: { silentMode in beginPrayerSession(silentMode: silentMode) }
                    )
                }
            }
            .navigationTitle("Prayer")
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AlarmsView()) {
                        Image(systemName: "alarm.fill")
                            .foregroundColor(.altarOrange)
                    }
                }
            }
            .onAppear { handleStartPrayerIntentIfNeeded() }
            .onDisappear {
                timer?.invalidate()
                updateIdleTimer(shouldStayAwake: false)
            }
        }
    }

    private func beginPrayerSession(silentMode: Bool) {
        guard let session = dataStore.startPrayerSession(silentMode: silentMode) else { return }
        currentSession = session
        startTime = Date()
        remaining = duration
        isTimerRunning = true
        HapticManager.shared.trigger(.medium)
        updateIdleTimer(shouldStayAwake: true)
        startTimer()
        withAnimation(AltarAnimations.gentle) { isInPrayer = true }
    }

    private func endPrayerSession() {
        timer?.invalidate()
        guard let sessionId = currentSession?.id,
              let sessionStartTime = startTime else { return }
        
        let durationMinutes = Int((Date().timeIntervalSince(sessionStartTime)) / 60)
        dataStore.endPrayerSession(sessionId)
        
        // Track trophy progress
        TrophyManager.shared.trackPrayerSession(
            durationMinutes: durationMinutes,
            startTime: sessionStartTime
        )
        
        HapticManager.shared.trigger(.light)
        updateIdleTimer(shouldStayAwake: false)
        withAnimation(AltarAnimations.gentle) {
            isInPrayer = false
            currentSession = nil
            startTime = nil
            isTimerRunning = false
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if isTimerRunning && remaining > 0 {
                remaining -= 1
                if remaining <= 0 {
                    isTimerRunning = false
                    HapticManager.shared.trigger(.heavy)
                }
            }
        }
    }

    private func handleStartPrayerIntentIfNeeded() {
        guard !isInPrayer else { return }
        let timestamp = UserDefaults.standard.double(forKey: "intent.startPrayer.timestamp")
        guard timestamp > 0 else { return }

        let age = Date().timeIntervalSince1970 - timestamp
        guard age >= 0, age < 60 else { return }

        let minutes = UserDefaults.standard.integer(forKey: "intent.startPrayer.minutes")
        UserDefaults.standard.removeObject(forKey: "intent.startPrayer.timestamp")
        UserDefaults.standard.removeObject(forKey: "intent.startPrayer.minutes")

        if minutes > 0 {
            duration = TimeInterval(minutes * 60)
            remaining = duration
        }
        beginPrayerSession(silentMode: false)
    }

    private func updateIdleTimer(shouldStayAwake: Bool) {
        #if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = shouldStayAwake
        #endif
    }
}

// MARK: - Pre Prayer View (with Duration Selection)
struct PrePrayerView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Binding var duration: TimeInterval
    let onBegin: (Bool) -> Void

    private let presets: [Int] = [5, 10, 15, 20, 30, 45, 60]
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: AltarSpacing.extraLarge) {
            Spacer()

            // Sacred Flame Icon
            VStack(spacing: 12) {
                SacredFlameIcon(size: 80, colorTheme: dataStore.flameColorTheme)

                Text("Ignite Prayer")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Set a focus timer and keep your altar burning.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .scaleEffect(hasAppeared ? 1.0 : 0.8)
            .opacity(hasAppeared ? 1.0 : 0)
            .animation(AltarAnimations.slideIn, value: hasAppeared)

            // Timer Display
            Text(timeString(duration))
                .font(.system(size: 60, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)
                .padding(.vertical)

            // Duration Slider
            VStack(spacing: 8) {
                Text("Duration: \(Int(duration / 60)) min")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Slider(
                    value: Binding(
                        get: { duration / 60 },
                        set: { duration = $0.rounded() * 60 }
                    ),
                    in: 5...120,
                    step: 5
                )
                .tint(.altarRed)
                .padding(.horizontal)
            }

            // Preset Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { minutes in
                        Button(action: {
                            HapticManager.shared.trigger(.light)
                            duration = TimeInterval(minutes * 60)
                        }) {
                            Text("\(minutes)m")
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Int(duration / 60) == minutes
                                        ? Color.altarRed
                                        : Color.white.opacity(0.1)
                                )
                                .foregroundColor(
                                    Int(duration / 60) == minutes ? .white : .white.opacity(0.7)
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Action Buttons
            VStack(spacing: AltarSpacing.medium) {
                Button(action: { onBegin(false) }) {
                    HStack(spacing: 8) {
                        SacredFlameIcon(size: 24, colorTheme: dataStore.flameColorTheme)
                        Text("Start Prayer")
                    }
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.altarRed, .altarOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .altarRed.opacity(0.4), radius: 15, x: 0, y: 5)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { onBegin(true) }) {
                    HStack {
                        Image(systemName: "wind")
                        Text("Silent prayer")
                    }
                    .font(.headline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, AltarSpacing.large)
            .padding(.bottom, AltarSpacing.extraLarge)
        }
        .onAppear { hasAppeared = true }
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds))
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Active Prayer View (with Timer + Scripture)
struct ActivePrayerView: View {
    @EnvironmentObject var dataStore: AppDataStore
    let session: PrayerSession?
    let startTime: Date
    let duration: TimeInterval
    @Binding var remaining: TimeInterval
    @Binding var isTimerRunning: Bool
    let onEnd: () -> Void

    @State private var showAddPrayer = false

    var prayLaterVerses: [VerseAction] { dataStore.getPrayLaterVerses() }
    var verseReflections: [PrayerItem] { dataStore.prayerItems.filter { $0.type == .verseReflection && !$0.answered } }
    var activePrayers: [PrayerItem] { dataStore.prayerItems.filter { $0.type == .personal && !$0.answered } }

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return (duration - remaining) / duration
    }

    private var timeString: String {
        let total = Int(max(0, remaining))
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AltarSpacing.large) {
                // Timer Section
                VStack(spacing: AltarSpacing.medium) {
                    // Progress Ring with Flame
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 8)
                            .frame(width: 160, height: 160)

                        // Progress circle
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [.altarRed, .altarOrange, .altarYellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)

                        // Center content
                        VStack(spacing: 4) {
                            SacredFlameIcon(size: 40, colorTheme: dataStore.flameColorTheme)

                            Text(timeString)
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.white)
                        }
                    }
                    .fireGlow(radius: 30)

                    // Timer Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            isTimerRunning.toggle()
                            HapticManager.shared.trigger(.light)
                        }) {
                            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.altarRed)
                                .clipShape(Circle())
                        }

                        Button(action: {
                            onEnd()
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }

                    if remaining <= 0 {
                        Text("Prayer Complete!")
                            .font(.headline)
                            .foregroundColor(.altarYellow)
                            .padding(.top)
                    }
                }
                .padding(.top, AltarSpacing.large)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal)

                // Content Section (Silent mode vs Active mode)
                if session?.silentMode == true {
                    VStack(spacing: AltarSpacing.large) {
                        GlowingCircle(size: 100, color: .altarRed)

                        Text("Be still and know...")
                            .font(.title3.weight(.medium))
                            .foregroundColor(.white.opacity(0.8))
                            .italic()
                    }
                    .padding(.vertical, AltarSpacing.extraLarge)
                } else {
                    VStack(alignment: .leading, spacing: AltarSpacing.large) {
                        // Section header
                        HStack {
                            Rectangle()
                                .fill(Color.altarRed)
                                .frame(width: 3, height: 20)
                            Text("Your Prayer List")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.altarOrange)
                        }
                        .padding(.horizontal)

                        // Scripture section
                        if !prayLaterVerses.isEmpty {
                            VStack(alignment: .leading, spacing: AltarSpacing.small) {
                                Text("SCRIPTURE")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.horizontal)

                                ForEach(Array(prayLaterVerses.enumerated()), id: \.element.id) { index, verse in
                                    PrayerItemCard(
                                        title: verse.verseId,
                                        content: verse.content ?? "",
                                        accentColor: .altarOrange
                                    )
                                    .slideIn(delay: Double(index) * 0.1)
                                }
                            }
                        }

                        // Verse Reflections section (Prayer Points from Bible)
                        if !verseReflections.isEmpty {
                            VStack(alignment: .leading, spacing: AltarSpacing.small) {
                                Text("VERSE REFLECTIONS")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.horizontal)

                                ForEach(Array(verseReflections.enumerated()), id: \.element.id) { index, prayer in
                                    VersePrayerPointCard(
                                        verseId: prayer.verseId ?? "",
                                        content: prayer.content,
                                        onMarkAnswered: {
                                            withAnimation(AltarAnimations.bouncy) {
                                                dataStore.markPrayerAnswered(prayer.id)
                                                HapticManager.shared.trigger(.medium)
                                            }
                                        }
                                    )
                                    .slideIn(delay: Double(index) * 0.1)
                                }
                            }
                        }

                        // Prayer points section
                        if !activePrayers.isEmpty {
                            VStack(alignment: .leading, spacing: AltarSpacing.small) {
                                Text("PRAYER POINTS")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.horizontal)

                                ForEach(Array(activePrayers.enumerated()), id: \.element.id) { index, prayer in
                                    SwipeablePrayerCard(prayer: prayer) {
                                        withAnimation(AltarAnimations.bouncy) {
                                            dataStore.markPrayerAnswered(prayer.id)
                                            HapticManager.shared.trigger(.medium)
                                        }
                                    }
                                    .slideIn(delay: Double(index) * 0.1)
                                }
                            }
                        }

                        // Empty state
                        if prayLaterVerses.isEmpty && verseReflections.isEmpty && activePrayers.isEmpty {
                            VStack(spacing: AltarSpacing.medium) {
                                SacredFlameIcon(size: 50, colorTheme: dataStore.flameColorTheme)
                                    .opacity(0.6)

                                Text("Your altar is ready.")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                                    .italic()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AltarSpacing.large)
                        }

                        // Add prayer button
                        Button(action: { showAddPrayer = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Prayer Point")
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.altarRed)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.altarRed.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.altarRed.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer(minLength: 120)
            }
        }
        .overlay(alignment: .bottom) {
            Button(action: onEnd) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("End Session")
                }
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.altarRed.opacity(0.8))
                )
            }
            .padding(.horizontal, AltarSpacing.large)
            .padding(.bottom, AltarSpacing.extraLarge)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 150)
                .allowsHitTesting(false)
            )
        }
        .sheet(isPresented: $showAddPrayer) { AddPrayerView() }
    }
}

// MARK: - Prayer Item Card
struct PrayerItemCard: View {
    let title: String
    let content: String
    var accentColor: Color = .altarRed

    var body: some View {
        VStack(alignment: .leading, spacing: AltarSpacing.small) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundColor(accentColor)
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Verse Prayer Point Card
struct VersePrayerPointCard: View {
    let verseId: String
    let content: String
    let onMarkAnswered: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Verse reference badge
            HStack {
                Image(systemName: "book.fill")
                    .font(.caption2)
                    .foregroundColor(.altarYellow)
                Text(verseId)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.altarYellow)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.altarYellow.opacity(0.2))
            .cornerRadius(8)

            // Verse content
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)

            // Mark as answered button
            Button(action: onMarkAnswered) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text("Mark as Answered")
                        .font(.caption.weight(.medium))
                }
                .foregroundColor(.altarSuccess)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.altarYellow.opacity(0.12), Color.altarOrange.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.altarYellow.opacity(0.35), lineWidth: 1.5)
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Swipeable Prayer Card
struct SwipeablePrayerCard: View {
    let prayer: PrayerItem
    let onMarkAnswered: () -> Void
    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            // Revealed action
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.altarSuccess)
                    .padding(.trailing, 20)
            }

            // Main content
            HStack(alignment: .top) {
                Text(prayer.content)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Button(action: onMarkAnswered) {
                    Image(systemName: "checkmark.circle")
                        .font(.title3)
                        .foregroundColor(.altarRed)
                }
            }
            .padding()
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.altarRed.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(12)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            offset = gesture.translation.width
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.width < -100 {
                            withAnimation(AltarAnimations.bouncy) {
                                offset = -300
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onMarkAnswered()
                            }
                        } else {
                            withAnimation(AltarAnimations.bouncy) {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Add Prayer View
struct AddPrayerView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) var dismiss
    @State private var prayerText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: AltarSpacing.large) {
                Text("Add Prayer Point")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.top)

                TextEditor(text: $prayerText)
                    .frame(height: 150)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)

                Button(action: {
                    if !prayerText.isEmpty {
                        dataStore.addPrayerItem(type: .personal, content: prayerText)
                        dismiss()
                    }
                }) {
                    Text("Add")
                        .font(.headline.bold())
                        .foregroundColor(prayerText.isEmpty ? .gray : .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(prayerText.isEmpty ? Color.gray.opacity(0.3) : Color.altarRed)
                        .cornerRadius(12)
                }
                .disabled(prayerText.isEmpty)
                .padding(.horizontal)

                Spacer()
            }
            .background(Color.altarBlack.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Remembered View
struct RememberedView: View {
    @EnvironmentObject var dataStore: AppDataStore
    var rememberedPrayers: [PrayerItem] { dataStore.getRememberedPrayers() }

    var body: some View {
        NavigationStack {
            ScrollView {
                if rememberedPrayers.isEmpty {
                    VStack(spacing: AltarSpacing.medium) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.altarRed.opacity(0.5))

                        Text("No answered prayers yet")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text("Prayers you mark as answered will appear here")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 100)
                } else {
                    VStack(spacing: AltarSpacing.medium) {
                        ForEach(rememberedPrayers) { prayer in
                            VStack(alignment: .leading, spacing: AltarSpacing.small) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.altarSuccess)
                                    if let answeredDate = prayer.answeredAt {
                                        Text(answeredDate, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                Text(prayer.content)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Remembered")
            .background(Color.altarBlack.ignoresSafeArea())
            .preferredColorScheme(.dark)
        }
    }
}
