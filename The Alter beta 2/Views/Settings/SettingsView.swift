import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showEditCommitment = false
    @State private var hapticsEnabled = true
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AltarSpacing.large) {
                        // Profile Header
                        if let commitment = dataStore.commitmentProfile {
                            ProfileHeader(commitment: commitment, onEdit: { showEditCommitment = true })
                                .slideIn(delay: 0.1)
                        }

                        // Quick Actions
                        VStack(spacing: AltarSpacing.medium) {
                            SettingsSectionHeader(title: "Quick Actions", icon: "bolt.fill")
                                .slideIn(delay: 0.2)

                            NavigationLink(destination: AlarmsView()) {
                                SettingsRow(
                                    icon: "alarm.fill",
                                    iconColor: .orange,
                                    title: "Prayer Alarms",
                                    subtitle: "Set daily reminders"
                                )
                            }
                            .buttonStyle(SettingsRowButtonStyle())
                            .slideIn(delay: 0.25)

                            NavigationLink(destination: RememberedView()) {
                                SettingsRow(
                                    icon: "heart.fill",
                                    iconColor: .altarSuccess,
                                    title: "Remembered",
                                    subtitle: "View answered prayers"
                                )
                            }
                            .buttonStyle(SettingsRowButtonStyle())
                            .slideIn(delay: 0.3)

                            NavigationLink(destination: NotesListView()) {
                                SettingsRow(
                                    icon: "note.text",
                                    iconColor: .blue,
                                    title: "My Notes",
                                    subtitle: "View all Bible notes"
                                )
                            }
                            .buttonStyle(SettingsRowButtonStyle())
                            .slideIn(delay: 0.33)

                            NavigationLink(destination: AchievementsView()) {
                                SettingsRow(
                                    icon: "trophy.fill",
                                    iconColor: .altarYellow,
                                    title: "Achievements",
                                    subtitle: "Track your progress"
                                )
                            }
                            .buttonStyle(SettingsRowButtonStyle())
                            .slideIn(delay: 0.36)

                            NavigationLink(destination: MyHighlightsView()) {
                                SettingsRow(
                                    icon: "highlighter",
                                    iconColor: .yellow,
                                    title: "My Highlights",
                                    subtitle: "View and export highlights"
                                )
                            }
                            .buttonStyle(SettingsRowButtonStyle())
                            .slideIn(delay: 0.39)
                        }
                        .padding(.horizontal)

                        // Reading Preferences
                        VStack(spacing: AltarSpacing.medium) {
                            SettingsSectionHeader(title: "Reading", icon: "book.fill")
                                .slideIn(delay: 0.35)

                            // Font Size
                            VStack(alignment: .leading, spacing: AltarSpacing.small) {
                                HStack {
                                    Image(systemName: "textformat.size")
                                        .foregroundColor(.altarOrange)
                                        .frame(width: 24)
                                    Text("Font Size")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(dataStore.bibleFontSize))pt")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }

                                Slider(value: $dataStore.bibleFontSize, in: 14...28, step: 1)
                                    .tint(.altarOrange)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .slideIn(delay: 0.4)

                            // Line Spacing
                            VStack(alignment: .leading, spacing: AltarSpacing.small) {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.altarYellow)
                                        .frame(width: 24)
                                    Text("Line Spacing")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(dataStore.bibleLineSpacing))pt")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }

                                Slider(value: $dataStore.bibleLineSpacing, in: 4...16, step: 2)
                                    .tint(.altarYellow)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .slideIn(delay: 0.45)

                            // Continuous Scrolling Toggle
                            HStack {
                                Image(systemName: "scroll.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                Text("Continuous Scrolling")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: $dataStore.bibleContinuousMode)
                                    .labelsHidden()
                                    .tint(.altarOrange)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .slideIn(delay: 0.5)
                        }
                        .padding(.horizontal)

                        // App Preferences
                        VStack(spacing: AltarSpacing.medium) {
                            SettingsSectionHeader(title: "Preferences", icon: "gearshape.fill")
                                .slideIn(delay: 0.5)

                            SettingsToggleRow(
                                icon: "hand.tap.fill",
                                iconColor: .purple,
                                title: "Haptic Feedback",
                                subtitle: "Vibration on interactions",
                                isOn: $hapticsEnabled
                            )
                            .onChange(of: hapticsEnabled) { _, newValue in
                                HapticManager.shared.setEnabled(newValue)
                            }
                            .slideIn(delay: 0.55)
                        }
                        .padding(.horizontal)

                        // About
                        VStack(spacing: AltarSpacing.medium) {
                            SettingsSectionHeader(title: "About", icon: "info.circle.fill")
                                .slideIn(delay: 0.6)

                            VStack(spacing: 0) {
                                SettingsInfoRow(title: "App Name", value: "The Altar")
                                Divider().background(Color.white.opacity(0.1))
                                SettingsInfoRow(title: "Version", value: "2.0 Beta")
                            }
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .slideIn(delay: 0.65)

                            // Footer quote
                            Text("A meeting place where you return daily to be loved by God, shaped by His Word, and formed into who you were created to be.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .padding(.top, AltarSpacing.medium)
                                .slideIn(delay: 0.7)
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 50)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Settings")
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showEditCommitment) {
                if let commitment = dataStore.commitmentProfile {
                    EditCommitmentView(commitment: commitment)
                }
            }
            .onAppear {
                hapticsEnabled = HapticManager.shared.isEnabled
                hasAppeared = true
            }
        }
    }
}

// MARK: - Profile Header
struct ProfileHeader: View {
    let commitment: CommitmentProfile
    let onEdit: () -> Void
    @State private var glowAmount: CGFloat = 0.3

    var body: some View {
        VStack(spacing: AltarSpacing.medium) {
            // Identity badge
            ZStack {
                Circle()
                    .fill(Color.altarSoftGold.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .shadow(color: .altarSoftGold.opacity(glowAmount), radius: 20, x: 0, y: 0)

                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.altarSoftGold)
            }

            VStack(spacing: 4) {
                Text(commitment.identityClass.rawValue)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)

                Text(commitment.identityClass.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Button(action: onEdit) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Commitment")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.altarSoftGold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.altarSoftGold.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.altarSoftGold.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.altarSoftGold.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .onAppear {
            withAnimation(AltarAnimations.glowPulse) {
                glowAmount = 0.5
            }
        }
    }
}

// MARK: - Settings Section Header
struct SettingsSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.altarSoftGold)
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundColor(.altarSoftGold)
            Spacer()
        }
    }
}

// MARK: - Settings Row Button Style
struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.white.opacity(configuration.isPressed ? 0.08 : 0.06))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AltarAnimations.cardPress, value: configuration.isPressed)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    // Internal state handling removed to fix NavigationLink conflict

    var body: some View {
        HStack(spacing: AltarSpacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        // Background and interaction handled by SettingsRowButtonStyle
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: AltarSpacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(.altarSoftGold)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
}

// MARK: - Settings Info Row
struct SettingsInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
    }
}

// MARK: - Edit Commitment View

struct EditCommitmentView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) var dismiss

    let commitment: CommitmentProfile

    @State private var bibleReads: Int
    @State private var prayerMinutes: Int

    init(commitment: CommitmentProfile) {
        self.commitment = commitment
        _bibleReads = State(initialValue: commitment.bibleReadsTarget)
        _prayerMinutes = State(initialValue: commitment.prayerMinutesTarget)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AltarSpacing.large) {
                    VStack(spacing: AltarSpacing.medium) {
                        Text("Update Your Commitment")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.top)

                        Text("You can adjust your commitment at any time. There's no pressure, only grace.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Bible Reads
                    VStack(alignment: .leading, spacing: AltarSpacing.small) {
                        Text("Bible Reads Before Year End")
                            .font(.headline)
                            .foregroundColor(.white)

                        Stepper(value: $bibleReads, in: 1...10) {
                            Text("\(bibleReads)×")
                                .font(.title.weight(.bold))
                                .foregroundColor(.altarSoftGold)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Prayer Minutes
                    VStack(alignment: .leading, spacing: AltarSpacing.small) {
                        Text("Daily Prayer Time")
                            .font(.headline)
                            .foregroundColor(.white)

                        Picker("Prayer Minutes", selection: $prayerMinutes) {
                            Text("25 min").tag(25)
                            Text("45 min").tag(45)
                            Text("60 min").tag(60)
                            Text("75 min").tag(75)
                            Text("90 min").tag(90)
                            Text("120 min").tag(120)
                        }
                        .altarWheelPickerStyle()
                        .frame(height: 150)
                    }
                    .padding(.horizontal)

                    // New Identity Class Preview
                    let newClass = IdentityClass.from(bibleReads: bibleReads, prayerMinutes: prayerMinutes)
                    VStack(spacing: AltarSpacing.small) {
                        Text("You will become:")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))

                        Text(newClass.rawValue)
                            .font(.title.weight(.bold))
                            .foregroundColor(.altarSoftGold)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Spacer(minLength: 100)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationTitle("Edit Commitment")
            .altarTitleInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCommitment()
                    }
                    .foregroundColor(.altarSoftGold)
                }
            }
        }
    }

    private func saveCommitment() {
        guard var updatedCommitment = dataStore.commitmentProfile else { return }
        updatedCommitment.updateCommitment(bibleReads: bibleReads, prayerMinutes: prayerMinutes)
        dataStore.commitmentProfile = updatedCommitment
        HapticManager.shared.trigger(.medium)
        dismiss()
    }
}

// MARK: - Notes List View
struct NotesListView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showEditNote = false
    @State private var editingNote: VerseAction?

    var notes: [VerseAction] {
        dataStore.getNotes().sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if notes.isEmpty {
                    EmptyStateView(
                        icon: "note.text",
                        title: "No Notes Yet",
                        subtitle: "Notes you add while reading will appear here"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: AltarSpacing.medium) {
                            ForEach(notes) { note in
                                NoteCard(note: note, onEdit: {
                                    editingNote = note
                                    showEditNote = true
                                }, onDelete: {
                                    withAnimation(AltarAnimations.gentle) {
                                        dataStore.deleteNote(noteId: note.id)
                                    }
                                })
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Notes")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showEditNote) {
                if let note = editingNote {
                    EditNoteView(note: note)
                }
            }
        }
    }
}

// MARK: - Note Card
struct NoteCard: View {
    let note: VerseAction
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: AltarSpacing.small) {
            HStack {
                Text(note.verseId)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.altarOrange)
                Spacer()
                HStack(spacing: 16) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }

            if let verseContent = note.content {
                Text(verseContent)
                    .font(.subheadline.italic())
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }

            Divider().background(Color.white.opacity(0.2))

            if let noteText = note.noteText {
                Text(noteText)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
            }

            Text(note.createdAt, style: .date)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.altarOrange.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
        .alert("Delete Note", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("Are you sure you want to delete this note?")
        }
    }
}

// MARK: - Edit Note View
struct EditNoteView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) var dismiss
    let note: VerseAction
    @State private var noteText: String

    init(note: VerseAction) {
        self.note = note
        _noteText = State(initialValue: note.noteText ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AltarSpacing.large) {
                VStack(alignment: .leading, spacing: AltarSpacing.small) {
                    Text(note.verseId)
                        .font(.headline)
                        .foregroundColor(.altarOrange)

                    if let content = note.content {
                        Text(content)
                            .font(.body.italic())
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)

                TextEditor(text: $noteText)
                    .frame(minHeight: 200)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)

                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Edit Note")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dataStore.updateNote(noteId: note.id, noteText: noteText)
                        dismiss()
                    }
                    .foregroundColor(.altarOrange)
                    .disabled(noteText.isEmpty)
                }
            }
        }
    }
}
