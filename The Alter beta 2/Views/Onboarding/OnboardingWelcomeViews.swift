import SwiftUI

// MARK: - Container
struct OnboardingContainerView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var currentStep = 0
    @State private var bibleReads = 0
    @State private var prayerMinutes = 0
    @State private var selectedColorTheme: FlameColorTheme = .classic

    var body: some View {
        ZStack {
            switch currentStep {
            case 0:
                WelcomeView { currentStep = 1 }
            case 1:
                IdentityIntroView { currentStep = 2 }
            case 2:
                DecisionGateView { currentStep = 3 }
            case 3:
                BibleCommitmentView(selectedReads: $bibleReads) { currentStep = 4 }
            case 4:
                PrayerCommitmentView(selectedMinutes: $prayerMinutes) { currentStep = 5 }
            case 5:
                IdentityClassView(
                    bibleReads: bibleReads,
                    prayerMinutes: prayerMinutes,
                    identityClass: IdentityClass.from(bibleReads: bibleReads, prayerMinutes: prayerMinutes)
                ) { currentStep = 6 }
            case 6:
                FlameColorSelectionView(selectedTheme: $selectedColorTheme) { completeOnboarding() }
            default:
                Color.black.ignoresSafeArea()
            }
        }
    }

    private func completeOnboarding() {
        guard let userId = dataStore.currentUser?.id else { return }
        let commitment = CommitmentProfile(
            userId: userId,
            bibleReadsTarget: bibleReads,
            prayerMinutesTarget: prayerMinutes,
            endDate: BibleCalculator.defaultYearEndDate()
        )
        dataStore.flameColorTheme = selectedColorTheme
        dataStore.completeOnboarding(commitment: commitment)
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                NotificationManager.shared.registerCategoriesAndDelegate()
            }
        }
    }
}

// MARK: - Welcome
struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            AltarBackgroundView()
            
            VStack(spacing: AltarSpacing.extraLarge) {
                Spacer()
                VStack(spacing: AltarSpacing.large) {
                    Text("This is a meeting place.")
                        .font(.custom("Baskerville-Bold", size: 36))
                        .foregroundStyle(LinearGradient.altarMetallicGold)
                        .multilineTextAlignment(.center)
                        .sacredGlow()

                    Text("You are not here to try harder.\nYou are here to fall in love with God through His Word.")
                        .altarSerifBody()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("This app doesn't change you.\nGod will.")
                        .font(.custom("Baskerville-Italic", size: 20))
                        .foregroundColor(.altarGoldBase)
                        .multilineTextAlignment(.center)
                        .padding(.top, AltarSpacing.small)
                }
                Spacer()
                Spacer()
                Button(action: {
                    HapticManager.shared.buttonTap()
                    withAnimation(AltarAnimations.gentle) { onContinue() }
                }) {
                    Text("Continue")
                        .font(.custom("Baskerville-Bold", size: 18))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient.altarMetallicGold)
                        .cornerRadius(16)
                        .shadow(color: .altarGoldBase.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, AltarSpacing.large)
                .padding(.bottom, AltarSpacing.extraLarge)
            }
        }
    }
}

// MARK: - Identity Intro
struct IdentityIntroView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            AltarBackgroundView()
            
            VStack(spacing: AltarSpacing.extraLarge) {
                Spacer()
                VStack(spacing: AltarSpacing.large) {
                    Text("You are chosen.")
                        .font(.custom("Baskerville-Bold", size: 40))
                        .foregroundStyle(LinearGradient.altarMetallicGold)
                        .multilineTextAlignment(.center)
                        .sacredGlow()

                    VStack(spacing: AltarSpacing.medium) {
                        Text("You are loved by God.")
                            .altarSerifBody()
                            .multilineTextAlignment(.center)

                        Text("And loved and chosen people never remain small.")
                            .font(.custom("Baskerville-Italic", size: 22))
                            .foregroundColor(.altarGoldBase)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    Text("God is raising you up.")
                        .altarSerifBody()
                        .multilineTextAlignment(.center)
                        .padding(.top, AltarSpacing.small)

                    Text("This app is here to remind you, train you,\nand prepare your mind for what He has already planned.")
                        .font(.custom("Baskerville", size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, AltarSpacing.small)
                }
                Spacer()
                Spacer()
                Button(action: {
                    HapticManager.shared.buttonTap()
                    withAnimation(AltarAnimations.gentle) { onContinue() }
                }) {
                    Text("Continue")
                        .font(.custom("Baskerville-Bold", size: 18))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient.altarMetallicGold)
                        .cornerRadius(16)
                        .shadow(color: .altarGoldBase.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, AltarSpacing.large)
                .padding(.bottom, AltarSpacing.extraLarge)
            }
        }
    }
}

// MARK: - Decision Gate
struct DecisionGateView: View {
    let onDecide: () -> Void
    @State private var hasDecided = false

    var body: some View {
        ZStack {
            AltarBackgroundView()
            
            VStack(spacing: AltarSpacing.extraLarge) {
                Spacer()
                VStack(spacing: AltarSpacing.large) {
                    Text("Before this year ends…")
                        .font(.custom("Baskerville-Italic", size: 24))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)

                    Text("Make a commitment\nto change the trajectory of your life.")
                        .font(.custom("Baskerville-Bold", size: 30))
                        .foregroundStyle(LinearGradient.altarMetallicGold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .sacredGlow()

                    VStack(spacing: AltarSpacing.medium) {
                        Text("Reject normality.")
                            .font(.custom("Baskerville-Bold", size: 22))
                            .foregroundColor(.altarGoldBase)

                        Text("You are called to be greater.\nYou are called to be different.")
                            .altarSerifBody()
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AltarSpacing.medium)

                    Text("This is not pressure.\nIt's a choice.")
                        .font(.custom("Baskerville-Italic", size: 16))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.top, AltarSpacing.small)
                }
                Spacer()
                Spacer()
                Button(action: {
                    HapticManager.shared.trigger(.medium)
                    hasDecided = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(AltarAnimations.gentle) { onDecide() }
                    }
                }) {
                    Text("I choose to follow God")
                        .font(.custom("Baskerville-Bold", size: 20))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            hasDecided ?
                                LinearGradient.altarMetallicGold :
                                LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(16)
                        .scaleEffect(hasDecided ? 1.05 : 1.0)
                        .shadow(
                            color: hasDecided ? .altarGoldBase.opacity(0.6) : .white.opacity(0.1),
                            radius: hasDecided ? 20 : 5
                        )
                }
                .disabled(hasDecided)
                .padding(.horizontal, AltarSpacing.large)
                .padding(.bottom, AltarSpacing.extraLarge)
            }
        }
    }
}

// MARK: - Flame Color Selection
struct FlameColorSelectionView: View {
    @Binding var selectedTheme: FlameColorTheme
    let onComplete: () -> Void
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            AltarBackgroundView()
            
            ScrollView {
                VStack(spacing: AltarSpacing.extraLarge) {
                    Spacer(minLength: 40)
                    
                    VStack(spacing: AltarSpacing.large) {
                        Text("Choose your flame")
                            .font(.custom("Baskerville-Bold", size: 32))
                            .foregroundStyle(LinearGradient.altarMetallicGold)
                            .multilineTextAlignment(.center)
                            .sacredGlow()
                            .padding(.horizontal)
                        
                        Text("Select the color that represents your altar")
                            .altarSerifBody()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Preview flame
                        SacredFlameIcon(size: 100, colorTheme: selectedTheme)
                            .frame(height: 150)
                            .padding(.vertical, AltarSpacing.medium)
                    }
                    
                    // Color theme grid
                    VStack(spacing: AltarSpacing.medium) {
                        ForEach(FlameColorTheme.allCases) { theme in
                            colorThemeButton(theme: theme, isSelected: selectedTheme == theme)
                        }
                    }
                    .padding(.horizontal, AltarSpacing.large)
                    
                    Spacer(minLength: 100)
                }
            }
            
            VStack {
                Spacer()
                Button(action: {
                    HapticManager.shared.buttonTap()
                    withAnimation(AltarAnimations.gentle) { onComplete() }
                }) {
                    Text("Continue")
                        .font(.custom("Baskerville-Bold", size: 18))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient.altarMetallicGold)
                        .cornerRadius(16)
                        .shadow(color: .altarGoldBase.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, AltarSpacing.large)
                .padding(.bottom, AltarSpacing.extraLarge)
            }
        }
        .onAppear {
            withAnimation(AltarAnimations.slideIn) {
                hasAppeared = true
            }
        }
    }
    
    private func colorThemeButton(theme: FlameColorTheme, isSelected: Bool) -> some View {
        Button(action: {
            selectedTheme = theme
            HapticManager.shared.selectionChanged()
        }) {
            HStack(spacing: AltarSpacing.medium) {
                // Small flame preview
                SacredFlameIcon(size: 40, colorTheme: theme)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                    
                    Text(theme.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(theme.glowColor)
                }
            }
            .padding()
            .background(
                isSelected ?
                    Color.white.opacity(0.15) :
                    Color.white.opacity(0.05)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? theme.glowColor.opacity(0.6) : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(12)
        }
    }
}