import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @StateObject private var trophyManager = TrophyManager.shared
    @State private var hasAppeared = false
    @State private var showFlameDetails = false
    @State private var showTrophyCelebration = false
    @State private var unlockedTrophy: Trophy?

    // MARK: - Computed Properties
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Peace to you"
        }
    }

    private var userName: String {
        "Friend"
    }

    private var weeklyMinutes: Int {
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return dataStore.prayerSessions
            .filter { $0.startTime >= startOfWeek }
            .map { $0.durationMinutes }
            .reduce(0, +)
    }

    private var streakDays: Int {
        let calendar = Calendar.current
        let dates = Set(dataStore.prayerSessions.map { calendar.startOfDay(for: $0.startTime) })
        var streak = 0
        var day = calendar.startOfDay(for: Date())
        while dates.contains(day) {
            streak += 1
            if let prev = calendar.date(byAdding: .day, value: -1, to: day) { day = prev } else { break }
        }
        return streak
    }

    private var totalSessions: Int {
        dataStore.prayerSessions.count
    }

    private var flameIntensity: Double {
        trophyManager.getFlameIntensity()
    }
    
    private var currentFlameLevel: FlameLevel {
        FlameLevel.from(intensity: flameIntensity)
    }

    private var greetingSubtitle: String {
        if weeklyMinutes > 0 {
            return "This week: \(weeklyMinutes)m of prayer"
        }
        return "Ignite your altar today"
    }

    private var currentVerse: (text: String, reference: String) {
        let verses: [(String, String)] = [
            ("Pray without ceasing.", "1 Thessalonians 5:17"),
            ("The prayer of a righteous person has great power as it is working.", "James 5:16"),
            ("Ask, and it will be given to you; seek, and you will find.", "Matthew 7:7"),
            ("The Lord is near to all who call on him.", "Psalm 145:18"),
            ("Be constant in prayer.", "Romans 12:12"),
            ("Cast all your anxiety on him because he cares for you.", "1 Peter 5:7"),
            ("Call to me and I will answer you.", "Jeremiah 33:3"),
            ("Do not be anxious about anything, but in every situation, by prayer...", "Philippians 4:6"),
            ("In the morning you hear my voice.", "Psalm 5:3"),
            ("The Lord hears when I call to him.", "Psalm 4:3")
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let idx = day % verses.count
        return verses[idx]
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Flame Section
                    VStack(spacing: 8) {
                        Button(action: {
                            HapticManager.shared.trigger(.light)
                            showFlameDetails = true
                        }) {
                            FlameView(intensity: flameIntensity, colorTheme: dataStore.flameColorTheme)
                                .frame(height: 180)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .slideIn(delay: 0.1)

                        Text("\(greeting), \(userName)")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .slideIn(delay: 0.2)

                        Text(greetingSubtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .slideIn(delay: 0.3)

                        // Flame Level Badge
                        HStack(spacing: 12) {
                            Text(currentFlameLevel.displayName)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(dataStore.flameColorTheme.glowColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(dataStore.flameColorTheme.glowColor.opacity(0.15))
                                .cornerRadius(12)
                            
                            // Trophy indicator
                            if !trophyManager.trophies.isEmpty {
                                Button(action: {
                                    HapticManager.shared.trigger(.light)
                                    // Could show trophy details or celebration
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trophy.fill")
                                            .font(.caption)
                                        Text("\(trophyManager.trophies.filter { $0.isUnlocked }.count)/\(trophyManager.trophies.count)")
                                            .font(.caption2.weight(.semibold))
                                    }
                                    .foregroundColor(trophyManager.getCurrentTrophyTier().color)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(trophyManager.getCurrentTrophyTier().color.opacity(0.15))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .slideIn(delay: 0.4)
                    }
                    .padding(.top, 24)

                    // Analytics Section
                    analyticsSection
                        .slideIn(delay: 0.5)

                    // Quick Start Buttons
                    quickStartButtons
                        .slideIn(delay: 0.6)

                    // Verse of the Day
                    verseCard
                        .slideIn(delay: 0.7)

                    // Navigation Links
                    navigationSection
                        .slideIn(delay: 0.8)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Color.altarBlack.ignoresSafeArea())
            .navigationTitle("Home")
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showFlameDetails) {
                FlameDetailsSheet(
                    flameLevel: currentFlameLevel,
                    intensity: flameIntensity,
                    colorTheme: dataStore.flameColorTheme
                )
            }
            .sheet(isPresented: $showTrophyCelebration) {
                if let trophy = unlockedTrophy {
                    TrophyCelebrationView(trophy: trophy)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .trophyUnlocked)) { notification in
                if let trophy = notification.object as? Trophy {
                    unlockedTrophy = trophy
                    showTrophyCelebration = true
                }
            }
        }
    }

    // MARK: - Analytics Section
    @ViewBuilder
    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Week")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                metricCard(title: "Weekly", value: "\(weeklyMinutes)m")
                metricCard(title: "Streak", value: "\(streakDays)d")
                metricCard(title: "Sessions", value: "\(totalSessions)")
            }
            .frame(maxWidth: .infinity)
        }
        .altarCardStyle()
    }

    private func metricCard(title: String, value: String) -> some View {
        VStack {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.altarOrange)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.altarCard))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.altarCardBorder, lineWidth: 1))
    }

    // MARK: - Quick Start Buttons
    @ViewBuilder
    private var quickStartButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 8) {
                ForEach([10, 20, 30], id: \.self) { minutes in
                    Button(action: { quickStartPrayer(minutes: minutes) }) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.altarRed)
                            Text("\(minutes)m")
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.altarCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.altarRed.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .altarCardStyle()
    }

    private func quickStartPrayer(minutes: Int) {
        HapticManager.shared.trigger(.medium)
        NotificationCenter.default.post(
            name: .intentStartPrayer,
            object: nil,
            userInfo: ["minutes": minutes]
        )
    }

    // MARK: - Verse Card
    @ViewBuilder
    private var verseCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "book.fill")
                    .foregroundColor(.altarRed)
                Text("Verse of the Day")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Text(currentVerse.text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .italic()

            Text(currentVerse.reference)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .altarCardStyle()
    }

    // MARK: - Navigation Section
    @ViewBuilder
    private var navigationSection: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: BibleReaderView()) {
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.altarOrange)
                    Text("Read Scripture")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding()
                .background(Color.altarCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.altarCardBorder, lineWidth: 1)
                )
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: MeetingPlaceView()) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.altarRed)
                    Text("Enter Prayer")
                        .foregroundColor(.white)
                    Spacer()
                    if dataStore.prayerItems.filter({ !$0.answered }).count > 0 {
                        Text("\(dataStore.prayerItems.filter({ !$0.answered }).count)")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.altarOrange)
                            .cornerRadius(10)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding()
                .background(Color.altarCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.altarCardBorder, lineWidth: 1)
                )
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())

            // Identity Class display if available
            if let commitment = dataStore.commitmentProfile {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.altarYellow)
                    VStack(alignment: .leading) {
                        Text(commitment.identityClass.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(commitment.bibleReadsTarget)x Bible / \(commitment.prayerMinutesTarget)m prayer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.altarCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.altarYellow.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppDataStore())
}
