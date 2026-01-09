import SwiftUI

struct RemindersView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var showingAlarms = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    nextPrayerCard
                    plannedTimeCard
                    todayScheduleSection
                }
                .padding()
            }
            .background(Color.altarBlack.ignoresSafeArea())
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .altarTrailing) {
                    Button {
                        showingAlarms = true
                    } label: {
                        Label("Manage Alarms", systemImage: "alarm")
                    }
                }
            }
            .sheet(isPresented: $showingAlarms) {
                AlarmsView()
                    .environmentObject(store)
            }
        }
    }

    private var nextPrayerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "alarm")
                    .foregroundStyle(.tint)
                Text("Next Prayer")
                    .font(.headline)
            }
            if let next = nextAlarmDate() {
                Text(dateTimeString(next))
                    .font(.title3.bold())
                Text(timeUntilString(next))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("No alarms set")
                    .foregroundStyle(.secondary)
            }
        }
        .altarCardStyle()
    }

    private var plannedTimeCard: some View {
        let count = todayEnabledAlarms().count
        let perSession = defaultSessionMinutes
        let minutes = count * perSession
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "clock")
                    .foregroundStyle(.tint)
                Text("Planned Today")
                    .font(.headline)
            }
            HStack {
                Text("\(minutes) minutes")
                    .font(.title3.bold())
                Spacer()
                Text("\(count) sessions • \(perSession)m each")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .altarCardStyle()
    }

    private var defaultSessionMinutes: Int {
        let value = UserDefaults.standard.integer(forKey: "settings.defaultSessionMinutes")
        return value > 0 ? value : 20
    }

    private var todayScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Schedule")
                .font(.headline)
            if todayEnabledAlarms().isEmpty {
                Text("No alarms for today")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(todayEnabledAlarms()) { alarm in
                    scheduleRow(for: alarm)
                }
            }
        }
        .altarCardStyle()
    }

    private func scheduleRow(for alarm: Alarm) -> some View {
        let statusStyle: AnyShapeStyle = alarm.isEnabled ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.gray)
        return HStack {
            Text(String(format: "%02d:%02d", alarm.hour, alarm.minute))
                .font(.headline)
            Spacer()
            Text(alarm.isEnabled ? "Enabled" : "Disabled")
                .font(.caption)
                .foregroundStyle(statusStyle)
        }
    }

    private func nextAlarmDate() -> Date? {
        let now = Date()
        let cal = Calendar.current
        var candidates: [Date] = []
        for alarm in store.alarms where alarm.isEnabled {
            var comps = cal.dateComponents([.year, .month, .day], from: now)
            comps.hour = alarm.hour
            comps.minute = alarm.minute
            if let today = cal.date(from: comps) {
                if today > now {
                    candidates.append(today)
                } else if let tomorrow = cal.date(byAdding: .day, value: 1, to: today) {
                    candidates.append(tomorrow)
                }
            }
        }
        return candidates.sorted().first
    }

    private func todayEnabledAlarms() -> [Alarm] {
        store.alarms
            .filter { $0.isEnabled }
            .sorted { a, b in
                if a.hour == b.hour { return a.minute < b.minute }
                return a.hour < b.hour
            }
    }

    private func dateTimeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func timeUntilString(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: Date(), to: date)
        let h = comps.hour ?? 0
        let m = comps.minute ?? 0
        if h > 0 { return "in \(h)h \(m)m" }
        return "in \(m)m"
    }
}
