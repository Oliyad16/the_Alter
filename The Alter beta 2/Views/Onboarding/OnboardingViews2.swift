import SwiftUI

// MARK: - Bible Commitment
struct BibleCommitmentView: View {
    @Binding var selectedReads: Int
    @State private var customReads: String = ""
    @State private var showCustomInput = false
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: AltarSpacing.large) {
                    VStack(spacing: AltarSpacing.medium) {
                        Text("How many times do you want to read the Bible before this year ends?")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 60)
                    }

                    VStack(spacing: AltarSpacing.medium) {
                        commitmentButton(reads: 1, isSelected: selectedReads == 1)
                        commitmentButton(reads: 2, isSelected: selectedReads == 2)
                        commitmentButton(reads: 3, isSelected: selectedReads == 3)

                        Button(action: {
                            showCustomInput.toggle()
                            HapticManager.shared.selectionChanged()
                        }) {
                            Text("Custom")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(showCustomInput ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(showCustomInput ? Color.white : Color.white.opacity(0.1))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.3), lineWidth: 1))
                                .cornerRadius(12)
                        }

                        if showCustomInput {
                            TextField("Enter number", text: $customReads)
                                .altarNumberPadKeyboard()
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .onChange(of: customReads) { newValue in
                                    if let value = Int(newValue), value > 0 {
                                        selectedReads = value
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, AltarSpacing.large)

                    if selectedReads > 0 {
                        let calculation = BibleCalculator.calculate(bibleReads: selectedReads, endDate: BibleCalculator.defaultYearEndDate())
                        VStack(spacing: AltarSpacing.small) {
                            Text(calculation.chaptersDisplayRange)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.altarSoftGold)
                            Text(calculation.displayRange)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Are you ready to pay the cost?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .italic()
                                .padding(.top, AltarSpacing.small)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, AltarSpacing.large)
                        .transition(.opacity)
                    }
                    Spacer(minLength: 100)
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    HapticManager.shared.buttonTap()
                    withAnimation(AltarAnimations.gentle) { onContinue() }
                }) {
                    Text("Continue")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedReads > 0 ? Color.white : Color.white.opacity(0.3))
                        .cornerRadius(16)
                }
                .disabled(selectedReads == 0)
                .padding(.horizontal, AltarSpacing.large)
                .padding(.bottom, AltarSpacing.extraLarge)
            }
        }
    }

    private func commitmentButton(reads: Int, isSelected: Bool) -> some View {
        Button(action: {
            selectedReads = reads
            showCustomInput = false
            customReads = ""
            HapticManager.shared.selectionChanged()
        }) {
            HStack {
                Text("\(reads)×")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(isSelected ? .black : .white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(isSelected ? Color.white : Color.white.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.clear : Color.white.opacity(0.3), lineWidth: 1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Prayer Commitment
struct PrayerCommitmentView: View {
    @Binding var selectedMinutes: Int
    let onContinue: () -> Void
    let options = [25, 45, 60, 75]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: AltarSpacing.large) {
                Spacer()
                VStack(spacing: AltarSpacing.medium) {
                    Text("God is waiting to talk to you.")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("How much time per day do you commit to Him?")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: AltarSpacing.medium) {
                    ForEach(options, id: \.self) { minutes in
                        prayerButton(minutes: minutes, isSelected: selectedMinutes == minutes)
                    }
                }
                .padding(.horizontal, AltarSpacing.large)
                .padding(.top, AltarSpacing.medium)

                Spacer()
                Spacer()
                Button(action: {
                    HapticManager.shared.buttonTap()
                    withAnimation(AltarAnimations.gentle) { onContinue() }
                }) {
                    Text("Continue")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedMinutes > 0 ? Color.white : Color.white.opacity(0.3))
                        .cornerRadius(16)
                }
                .disabled(selectedMinutes == 0)
                .padding(.horizontal, AltarSpacing.large)
                .padding(.bottom, AltarSpacing.extraLarge)
            }
        }
    }

    private func prayerButton(minutes: Int, isSelected: Bool) -> some View {
        Button(action: {
            selectedMinutes = minutes
            HapticManager.shared.selectionChanged()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(minutes) minutes")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isSelected ? .black : .white)
                    if minutes >= 60 {
                        Text("\(minutes / 60) hour\(minutes > 60 ? " \(minutes % 60) min" : "")")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(isSelected ? .black.opacity(0.7) : .white.opacity(0.6))
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(isSelected ? Color.white : Color.white.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.clear : Color.white.opacity(0.3), lineWidth: 1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Identity Class
struct IdentityClassView: View {
    let bibleReads: Int
    let prayerMinutes: Int
    let identityClass: IdentityClass
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: AltarSpacing.large) {
                    VStack(spacing: AltarSpacing.medium) {
                        Text("This is the direction you've chosen.")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.top, 60)

                        VStack(spacing: AltarSpacing.small) {
                            Text("Bible: \(bibleReads)× before year-end")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Prayer: \(prayerMinutes) min per day")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        Text("This isn't a vow.\nThis is a commitment.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .italic()
                            .padding(.top, AltarSpacing.small)
                    }
                    .padding(.horizontal)

                    VStack(spacing: AltarSpacing.small) {
                        Text("You have chosen to become:")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.altarSoftGold)
                        Text(identityClass.rawValue)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, AltarSpacing.tiny)
                    }
                    .padding(.top, AltarSpacing.large)

                    VStack(spacing: AltarSpacing.medium) {
                        ForEach(IdentityClass.allCases, id: \.self) { cls in
                            identityCard(for: cls, isSelected: cls == identityClass)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, AltarSpacing.medium)

                    Text("Nobody in the Bible became great by being normal.\nThey paid the price.\nThey made sacrifices.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.horizontal)
                        .padding(.vertical, AltarSpacing.large)

                    Spacer(minLength: 100)
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    HapticManager.shared.trigger(.medium)
                    withAnimation(AltarAnimations.gentle) { onComplete() }
                }) {
                    Text("Enter the meeting place")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, AltarSpacing.large)
                .padding(.bottom, AltarSpacing.extraLarge)
            }
        }
    }

    private func identityCard(for cls: IdentityClass, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: AltarSpacing.small) {
            HStack {
                Text(cls.rawValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isSelected ? .altarSoftGold : .white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.altarSoftGold)
                }
            }
            Text(cls.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.altarSoftGold.opacity(0.5) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1))
        .cornerRadius(12)
    }
}
