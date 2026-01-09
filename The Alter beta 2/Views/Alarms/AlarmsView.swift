import SwiftUI

struct AlarmsView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var showingAdd = false
    @State private var showingEdit: Alarm? = nil

    var body: some View {
        NavigationStack {
            List {
                if store.alarms.isEmpty {
                    Section { emptyState } footer: { EmptyView() }
                } else {
                    ForEach(store.alarms) { alarm in
                        Button(action: { showingEdit = alarm }) {
                            AlarmRow(alarm: alarm)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        indexSet.map { store.alarms[$0] }.forEach { store.removeAlarm($0) }
                    }
                }
            }
            .navigationTitle("Alarms")
            .altarTitleLarge()
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .background(Color.altarBlack.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .altarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AlarmFormView { newAlarm in
                    store.addAlarm(newAlarm)
                }
            }
            .sheet(item: $showingEdit) { alarm in
                AlarmFormView(onSave: { updated in
                    store.updateAlarm(updated)
                }, existing: alarm)
            }
        }
    }
}

private struct AlarmRow: View {
    @EnvironmentObject var store: AppDataStore
    let alarm: Alarm

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(alarm.title)
                    .font(.headline)
                HStack(spacing: 8) {
                    Image(systemName: "alarm")
                        .foregroundStyle(.secondary)
                    Text(timeAndRepeat)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if alarm.allowSnooze {
                    Text("Snooze enabled")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(String(format: "%02d:%02d", alarm.hour, alarm.minute))
                .font(.title2.bold())
                .monospacedDigit()
                .padding(.trailing, 4)
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { newValue in
                    var updated = alarm
                    updated.isEnabled = newValue
                    store.updateAlarm(updated)
                }
            ))
            .labelsHidden()
        }
        .altarCardStyle()
    }

    private var timeAndRepeat: String {
        let time = String(format: "%02d:%02d", alarm.hour, alarm.minute)
        if alarm.repeatWeekdays.isEmpty { return time + " • Daily" }
        let symbols = Calendar.current.shortWeekdaySymbols // Sun..Sat
        let text = alarm.repeatWeekdays.sorted().map { idx in
            let i = max(1, min(7, idx)) - 1
            return symbols[i]
        }.joined(separator: ", ")
        return time + " • " + text
    }
}

private extension AlarmsView {
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "alarm")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.secondary)
            Text("No alarms yet")
                .font(.headline)
            Text("Create prayer reminders to help you return to the meeting place.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: { showingAdd = true }) {
                Label("Add Alarm", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
    }
}

struct AlarmFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = "Alarm"
    @State private var time: Date = Date()
    @State private var repeatDaily: Bool = true
    @State private var selectedWeekdays: Set<Int> = []
    @State private var allowSnooze: Bool = true

    var onSave: (Alarm) -> Void
    var existing: Alarm? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionCard(title: "Details") {
                        VStack(spacing: 12) {
                            LabeledFieldRow(label: "Alarm") {
                                TextField("Title", text: $title)
                                    .altarWordsAutocapitalization()
                            }
                            Divider().overlay(Color.altarCardBorder)
                            LabeledFieldRow(label: "Time") {
                                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                        }
                    }

                    SectionCard(title: "Repeat") {
                        VStack(spacing: 12) {
                            Toggle("Repeat Daily", isOn: $repeatDaily)
                            if !repeatDaily {
                                WeekdayPicker(selected: $selectedWeekdays)
                            }
                        }
                    }

                    SectionCard(title: "Options") {
                        Toggle("Enable Snooze", isOn: $allowSnooze)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle(existing == nil ? "New Alarm" : "Edit Alarm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
                        var alarm = existing ?? Alarm(title: title.isEmpty ? "Alarm" : title, hour: comps.hour ?? 8, minute: comps.minute ?? 0, isEnabled: true)
                        alarm.title = title.isEmpty ? "Alarm" : title
                        alarm.hour = comps.hour ?? 8
                        alarm.minute = comps.minute ?? 0
                        alarm.allowSnooze = allowSnooze
                        alarm.repeatWeekdays = repeatDaily ? [] : Array(selectedWeekdays)
                        onSave(alarm)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let alarm = existing {
                    title = alarm.title
                    var comps = DateComponents()
                    comps.hour = alarm.hour
                    comps.minute = alarm.minute
                    time = Calendar.current.date(from: comps) ?? Date()
                    repeatDaily = alarm.repeatWeekdays.isEmpty
                    selectedWeekdays = Set(alarm.repeatWeekdays)
                    allowSnooze = alarm.allowSnooze
                }
            }
        }
    }
}

private struct WeekdayPicker: View {
    @Binding var selected: Set<Int> // 1...7 Sun=1
    private let days = Array(1...7)

    var body: some View {
        let symbols = Calendar.current.shortWeekdaySymbols
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { d in
                let isOn = selected.contains(d)
                SelectablePill(text: symbols[d - 1], isSelected: isOn) {
                    if isOn { selected.remove(d) } else { selected.insert(d) }
                }
            }
        }
    }
}

// MARK: - Styled helpers

private struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            content
        }
        .altarCardStyle()
    }
}

private struct LabeledFieldRow<Content: View>: View {
    let label: String
    @ViewBuilder var field: Content

    init(label: String, @ViewBuilder _ field: () -> Content) {
        self.label = label
        self.field = field()
    }

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            field
        }
    }
}

private struct SelectablePill: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.footnote.weight(.semibold))
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.accentColor.opacity(0.22) : Color.altarCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.altarCardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
