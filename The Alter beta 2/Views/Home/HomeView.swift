import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var hasAppeared = false

    // MARK: - Computed Properties
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
                    // Progress Dashboard
                    ProgressDashboard()
                        .slideIn(delay: 0.1)

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
            .onAppear {
                if !hasAppeared {
                    hasAppeared = true
                    dataStore.updateStreaks()
                }
            }
        }
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
