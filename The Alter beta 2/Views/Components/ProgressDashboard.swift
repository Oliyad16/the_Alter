import SwiftUI

struct ProgressDashboard: View {
    @EnvironmentObject var dataStore: AppDataStore

    var body: some View {
        VStack(spacing: 16) {
            // Greeting Header
            greetingSection

            // Streak Cards (Prayer & Reading)
            streakSection

            // Bible Progress Card
            if dataStore.commitmentProfile != nil {
                bibleProgressSection
            }

            // Weekly Summary
            weeklySummarySection
        }
        .padding(.top, 24)
    }

    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(spacing: 8) {
            Text("\(greeting), Friend")
                .font(.title.bold())
                .foregroundColor(.white)

            Text(greetingSubtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Peace to you"
        }
    }

    private var greetingSubtitle: String {
        let stats = dataStore.bibleProgressStats
        if stats.weeklyChaptersRead > 0 {
            return "This week: \(stats.weeklyChaptersRead) chapters read"
        }
        return "Ignite your altar today"
    }

    // MARK: - Streak Section
    private var streakSection: some View {
        HStack(spacing: 12) {
            // Prayer Streak
            streakCard(
                title: "Prayer",
                streakDays: dataStore.streakData.prayerStreak,
                icon: "flame.fill",
                color: .altarRed
            )

            // Reading Streak
            streakCard(
                title: "Reading",
                streakDays: dataStore.streakData.readingStreak,
                icon: "book.fill",
                color: .altarOrange
            )
        }
    }

    private func streakCard(title: String, streakDays: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text("\(streakDays)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)

            Text(streakDays == 1 ? "Day" : "Days")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.altarCard))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    // MARK: - Bible Progress Section
    private var bibleProgressSection: some View {
        let stats = dataStore.bibleProgressStats

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.altarYellow)
                Text("Bible Reading Goal")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(stats.chaptersCompleted) of \(stats.totalChaptersGoal) chapters")
                        .font(.subheadline)
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(Int(stats.percentComplete))%")
                        .font(.subheadline.bold())
                        .foregroundColor(.altarYellow)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)

                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.altarYellow, .altarOrange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: min(geometry.size.width * (stats.percentComplete / 100), geometry.size.width),
                                height: 12
                            )
                            .shadow(color: Color.altarYellow.opacity(0.5), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 12)
            }

            // Status Message
            HStack(spacing: 8) {
                Image(systemName: statusIcon(stats: stats))
                    .foregroundColor(statusColor(stats: stats))

                Text(stats.statusMessage)
                    .font(.subheadline)
                    .foregroundColor(statusColor(stats: stats))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(statusColor(stats: stats).opacity(0.1))
            )

            // Stats Grid
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stats.chaptersAheadOrBehind >= 0 ? "Ahead" : "Behind")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(abs(stats.chaptersAheadOrBehind)) ch")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Divider()
                    .frame(height: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Days Left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(stats.daysRemaining)")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Divider()
                    .frame(height: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Need/Day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", stats.updatedChaptersPerDay))
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 4)
        }
        .altarCardStyle()
    }

    private func statusIcon(stats: BibleProgressStats) -> String {
        if stats.chaptersCompleted >= stats.totalChaptersGoal {
            return "checkmark.circle.fill"
        } else if stats.chaptersAheadOrBehind > 5 {
            return "arrow.up.circle.fill"
        } else if stats.isOnTrack {
            return "checkmark.circle"
        } else {
            return "arrow.forward.circle"
        }
    }

    private func statusColor(stats: BibleProgressStats) -> Color {
        if stats.chaptersCompleted >= stats.totalChaptersGoal {
            return .altarSuccess
        } else if stats.chaptersAheadOrBehind > 5 {
            return .altarYellow
        } else if stats.isOnTrack {
            return .altarSuccess
        } else {
            return .altarOrange
        }
    }

    // MARK: - Weekly Summary
    private var weeklySummarySection: some View {
        let weeklyPrayerMinutes = getWeeklyPrayerMinutes()
        let stats = dataStore.bibleProgressStats

        return VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                // Weekly Prayer
                miniMetricCard(
                    icon: "flame.fill",
                    value: "\(weeklyPrayerMinutes)m",
                    label: "Prayer",
                    color: .altarRed
                )

                // Weekly Reading
                miniMetricCard(
                    icon: "book.fill",
                    value: "\(stats.weeklyChaptersRead)",
                    label: "Chapters",
                    color: .altarOrange
                )

                // Total Sessions
                miniMetricCard(
                    icon: "list.bullet",
                    value: "\(dataStore.prayerSessions.count)",
                    label: "Sessions",
                    color: .altarYellow
                )
            }
        }
        .altarCardStyle()
    }

    private func miniMetricCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)

            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.altarCard))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.altarCardBorder, lineWidth: 1))
    }

    private func getWeeklyPrayerMinutes() -> Int {
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return dataStore.prayerSessions
            .filter { $0.startTime >= startOfWeek }
            .map { $0.durationMinutes }
            .reduce(0, +)
    }
}

#Preview {
    ProgressDashboard()
        .environmentObject(AppDataStore())
        .background(Color.altarBlack)
}
