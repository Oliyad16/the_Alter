# App Store Submission Checklist
## "The Altar" - Quick Action Guide

**Priority:** Complete tasks in order (Critical → High → Medium → Low)

---

## CRITICAL TASKS (Must Complete Before Submission)

### 1. Add Privacy Manifest to Xcode Project
**Status:** ✅ File created at `/The Alter beta 2/PrivacyInfo.xcprivacy`
**Time:** 5 minutes

**Steps:**
1. Open `The Alter beta 2.xcodeproj` in Xcode
2. Right-click on "The Alter beta 2" folder in navigator
3. Select "Add Files to 'The Alter beta 2'..."
4. Navigate to and select `PrivacyInfo.xcprivacy`
5. Ensure "Add to targets: The Alter beta 2" is CHECKED
6. Click "Add"
7. Verify file appears in Project Navigator with target membership

**Verification:**
- Build project (Cmd+B)
- No errors should appear
- File should be included in app bundle

---

### 2. Remove Unused Location Permission
**Time:** 2 minutes

**Steps:**
1. In Xcode, select project (blue icon at top of navigator)
2. Select "The Alter beta 2" target
3. Click "Info" tab
4. Find key: `NSLocationWhenInUseUsageDescription`
5. Click the (-) button to DELETE this row
6. Save (Cmd+S)

**Verification:**
- Build and run app
- No location permission request should appear

---

### 3. Lower iOS Deployment Target
**Time:** 5 minutes

**Steps:**
1. Select project in Xcode
2. Select "The Alter beta 2" target
3. Click "General" tab
4. Under "Minimum Deployments", change iOS from `18.5` to `17.0`
5. Repeat for test targets if present

**Verification:**
- Build succeeds (Cmd+B)
- Test on iOS 17 simulator:
  - Product > Destination > Add Additional Simulators
  - Download iOS 17 simulator
  - Run app and verify all features work

---

### 4. Fix Bundle Identifier
**Time:** 10 minutes + certificate updates

**Steps:**
1. In Xcode: Target > General > Identity
2. Change Bundle Identifier from:
   `com.thelivingstonefoundation.The-Alter.The-Alter-beta-2`
   To:
   `com.thelivingstonefoundation.thealtar`
3. Go to Apple Developer portal (developer.apple.com)
4. Certificates, Identifiers & Profiles > Identifiers
5. Click (+) to create new App ID
6. Register new identifier: `com.thelivingstonefoundation.thealtar`
7. Update provisioning profiles in Xcode (Signing & Capabilities)

**Verification:**
- Clean build folder (Cmd+Shift+K)
- Build and run with new identifier
- Check code signing succeeds

---

### 5. Create Privacy Policy
**Time:** 2 hours

**Steps:**
1. Copy template from audit report (Section 2.4)
2. Customize with your contact information
3. Host at one of:
   - GitHub Pages (recommended for free)
   - Your organization website
   - Privacy policy hosting service

**For GitHub Pages:**
```bash
# Create new repository: thealtar-privacy
# Create file: index.html with privacy policy content
# Enable GitHub Pages in repository settings
# URL will be: https://[username].github.io/thealtar-privacy
```

**Save URL for use in:**
- App Store Connect metadata
- Info.plist (optional)
- About section in app

---

### 6. Add API.Bible Attribution
**Time:** 1 hour

**File to Edit:** `/The Alter beta 2/Views/Bible/BibleViews.swift`

**Add to BibleReaderView (after chapter content):**
```swift
// At bottom of chapter view, add:
VStack(spacing: 4) {
    Divider()
        .background(Color.white.opacity(0.2))
        .padding(.vertical, 8)

    Text("Scripture provided by API.Bible")
        .font(.caption)
        .foregroundColor(.white.opacity(0.5))

    Link("scripture.api.bible", destination: URL(string: "https://scripture.api.bible")!)
        .font(.caption)
        .foregroundColor(.altarGoldBase.opacity(0.7))
}
.padding(.horizontal)
.padding(.bottom, 16)
```

**File to Edit:** `/The Alter beta 2/Views/Settings/SettingsView.swift`

**Add new section (after Preferences section):**
```swift
// About Section
VStack(spacing: AltarSpacing.medium) {
    SettingsSectionHeader(title: "About", icon: "info.circle.fill")
        .slideIn(delay: 0.6)

    VStack(alignment: .leading, spacing: 12) {
        Text("Bible Content")
            .font(.headline)
            .foregroundColor(.white)

        Text("Scripture text provided by API.Bible")
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))

        Link("Visit API.Bible", destination: URL(string: "https://scripture.api.bible")!)
            .font(.subheadline)
            .foregroundColor(.altarGoldBase)

        Divider()
            .background(Color.white.opacity(0.2))
            .padding(.vertical, 4)

        Text("Translations")
            .font(.headline)
            .foregroundColor(.white)

        Text("KJV, NIV, ESV, NASB, NLT, NKJV, and others")
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))

        Divider()
            .background(Color.white.opacity(0.2))
            .padding(.vertical, 4)

        Text("Version")
            .font(.headline)
            .foregroundColor(.white)

        Text("The Altar 1.0")
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))
    }
    .padding()
    .background(Color.white.opacity(0.06))
    .cornerRadius(12)
    .slideIn(delay: 0.65)
}
.padding(.horizontal)
```

---

## HIGH PRIORITY TASKS

### 7. Optimize App Icon Assets
**Time:** 30 minutes

**Tools:**
- ImageOptim (free): https://imageoptim.com
- TinyPNG (online): https://tinypng.com

**Steps:**
1. Locate icon files:
   `/The Alter beta 2/Assets.xcassets/AppIcon.appiconset/`
2. Copy all PNG files to a backup folder
3. Drag all icon files into ImageOptim or upload to TinyPNG
4. Replace original files with optimized versions
5. Target: <100KB per file (currently 1MB each)

**Verification:**
- Icons still appear correctly in Xcode
- Build and check app icon on device/simulator

---

### 8. Create Support Resources
**Time:** 30 minutes

**Tasks:**
- [ ] Set up support email: support@thelivingstonefoundation.org (or similar)
- [ ] Create simple support page with:
  - FAQ
  - Contact information
  - Known issues (if any)
- [ ] Host support page at public URL
- [ ] Save URL for App Store Connect

**Sample FAQ Topics:**
- How do I change my Bible reading commitment?
- Can I use the app offline?
- How do I delete my data?
- Which Bible translations are available?
- How do I set prayer alarms?

---

### 9. Prepare App Store Screenshots
**Time:** 2 hours

**Required Sizes:**
- iPhone 6.7" (1290 x 2796 pixels) - REQUIRED
- iPhone 6.5" (1242 x 2688 pixels) - Recommended
- iPad Pro 12.9" (2048 x 2732 pixels) - If supporting iPad

**Required Screenshots (minimum 3, maximum 10):**

**Screenshot 1: Onboarding/Welcome**
- Shows "This is a meeting place" screen
- Highlights grace-centered approach

**Screenshot 2: Bible Reader**
- Shows chapter reading view
- Highlight verse action features

**Screenshot 3: Prayer Experience**
- Shows "The Meeting Place" prayer interface
- Demonstrates silent presence mode

**Screenshot 4 (Optional): Home Dashboard**
- Shows commitment summary
- Daily progress

**Screenshot 5 (Optional): Settings/Customization**
- Font settings
- Flame color themes

**Tools:**
- Xcode Simulator (take screenshots with Cmd+S)
- Screenshots.app (Mac App Store) - Adds device frames
- Figma/Canva - Add text overlays explaining features

**Tips:**
- Use consistent device frame across all screenshots
- Add brief text captions explaining each feature
- Maintain dark theme aesthetic
- Show actual app content (not Lorem ipsum)

---

### 10. Verify API Key is Production-Ready
**Time:** 15 minutes

**Steps:**
1. Log into API.Bible account (https://scripture.api.bible)
2. Verify key: `dI4FM0Jkmd_h7ZqQGglbZ` is:
   - Active and valid
   - Associated with your account (not a demo key)
   - Has adequate rate limits
3. Review rate limits:
   - Free tier: typically 100-500 requests/day
   - Confirm this is sufficient for your usage
4. Consider upgrading if needed (usually not required for individual users)

**Verification:**
- Test Bible reading in app
- Check multiple chapters load successfully
- Verify search functionality works

---

## MEDIUM PRIORITY TASKS

### 11. VoiceOver Testing
**Time:** 2 hours

**Steps:**
1. Enable VoiceOver: Settings > Accessibility > VoiceOver
2. Navigate app with VoiceOver gestures:
   - Swipe right: Next element
   - Swipe left: Previous element
   - Double tap: Activate
3. Test all screens:
   - Onboarding flow
   - Bible reader
   - Prayer session
   - Settings
   - Alarms
4. Verify all interactive elements have labels
5. Add accessibility labels where needed

**Common Issues to Fix:**
```swift
// Before (no label)
Image(systemName: "flame.fill")

// After (with label)
Image(systemName: "flame.fill")
    .accessibilityLabel("Sacred flame icon")

// Interactive elements
Button(action: startPrayer) {
    Text("Begin")
}
.accessibilityLabel("Start prayer session")
.accessibilityHint("Double tap to begin praying")
```

---

### 12. Dynamic Type Testing
**Time:** 1 hour

**Steps:**
1. Settings > Accessibility > Display & Text Size > Larger Text
2. Drag slider to largest size
3. Test all screens for:
   - Text truncation
   - Layout breaks
   - Overlapping elements
4. Test smallest size as well
5. Verify Bible reader font size control still works

**Fix Issues:**
- Use `.minimumScaleFactor()` for flexible text
- Use `lineLimit(nil)` for multi-line labels
- Test with `.font(.body)` instead of fixed sizes where possible

---

### 13. Error Scenario Testing
**Time:** 2 hours

**Test Cases:**

**1. No Internet Connection:**
- [ ] Enable Airplane Mode
- [ ] Try to load Bible chapter
- [ ] Verify cached chapters still work
- [ ] Verify error message is user-friendly

**2. Invalid API Key:**
- [ ] Temporarily change API key to "invalid"
- [ ] Try to load Bible content
- [ ] Verify error message guides user

**3. Denied Notification Permission:**
- [ ] Deny notifications during onboarding
- [ ] Try to set an alarm
- [ ] Verify app handles gracefully
- [ ] Test "Open Settings" flow

**4. Low Storage:**
- [ ] Test with limited device storage
- [ ] Verify app doesn't crash
- [ ] Graceful degradation if cache fails

**5. Background App Refresh:**
- [ ] Set alarms
- [ ] Completely quit app
- [ ] Wait for alarm time
- [ ] Verify notification fires

---

### 14. Color Contrast Verification
**Time:** 30 minutes

**Tool:** Use online contrast checker (e.g., WebAIM)

**Test Key Color Combinations:**
1. Gold text on black background
   - Target: 4.5:1 ratio for normal text
   - Target: 3:1 ratio for large text
2. White text on dark background
3. Button text on gold gradient

**Files to Check:**
- `/The Alter beta 2/Theme.swift`
- Verify all text colors meet WCAG AA standards

---

## LOW PRIORITY TASKS (Recommended)

### 15. Create App Preview Video
**Time:** 2-3 hours

**Specifications:**
- Length: 15-30 seconds
- Size: Same as screenshot sizes
- Format: MP4 or MOV
- No audio required (but can add music)

**Content Ideas:**
- Quick tour of onboarding
- Bible reading demonstration
- Prayer session flow
- Show alarm feature

**Tools:**
- QuickTime Screen Recording (Mac)
- iMovie (basic editing)
- Final Cut Pro (advanced)

---

### 16. Add Cache Management
**Time:** 2 hours

**Enhancement:** Add cache size monitoring and cleanup

**Add to AppDataStore.swift:**
```swift
func getCacheSizeMB() -> Double {
    let defaults = UserDefaults.standard
    let dict = defaults.dictionaryRepresentation()
    var totalSize = 0
    for (_, value) in dict {
        if let data = value as? Data {
            totalSize += data.count
        }
    }
    return Double(totalSize) / 1_048_576 // Convert to MB
}

func clearBibleCache() {
    let defaults = UserDefaults.standard
    let keys = defaults.dictionaryRepresentation().keys
    let cacheKeys = keys.filter { $0.hasPrefix("cached_chapter_") }
    cacheKeys.forEach { defaults.removeObject(forKey: $0) }
}
```

**Add to Settings:**
```swift
// Storage section
Text("Cache Size: \(String(format: "%.1f", dataStore.getCacheSizeMB())) MB")
Button("Clear Bible Cache") {
    dataStore.clearBibleCache()
}
```

---

### 17. Add App Rating Prompt
**Time:** 30 minutes

**Implementation:**
```swift
import StoreKit

// In appropriate location (after meaningful usage)
func requestReviewIfAppropriate() {
    let sessionCount = UserDefaults.standard.integer(forKey: "prayerSessionCount")
    let hasRequestedReview = UserDefaults.standard.bool(forKey: "hasRequestedReview")

    if sessionCount >= 5 && !hasRequestedReview {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            UserDefaults.standard.set(true, forKey: "hasRequestedReview")
        }
    }
}
```

**Trigger Points:**
- After 5 prayer sessions
- After completing 7 days of commitment
- Never more than once per app version

---

## APP STORE CONNECT SETUP

### 18. Complete App Information
**Platform:** App Store Connect (appstoreconnect.apple.com)

**Required Fields:**

**App Information:**
- [ ] Name: "The Altar"
- [ ] Subtitle: "Grace-centered spiritual growth"
- [ ] Privacy Policy URL: [YOUR URL FROM TASK #5]
- [ ] Primary Category: Lifestyle
- [ ] Secondary Category: Reference (optional)
- [ ] Content Rights: Check if you own rights to all content

**Pricing:**
- [ ] Price: Free
- [ ] Availability: All countries (or select specific)

**App Privacy:**
- [ ] Data Collection: None
- [ ] Tracking: No
- [ ] Third-party APIs: Yes (API.Bible for scripture)

---

### 19. Write App Description
**Character Limit:** 4000 characters

**Template:**
```
The Altar is a grace-centered prayer and Bible reading app designed for spiritual growth without pressure or performance.

THIS IS A MEETING PLACE

Not a productivity tool. Not a gamification system. Just a welcoming space to encounter God through His Word and prayer.

FEATURES

• Bible Reading
Read scripture from multiple translations including KJV, NIV, ESV, NASB, NLT, and NKJV. Powered by API.Bible.

• Personal Commitments
Set your own Bible reading and prayer goals—not to earn anything, but to shape your spiritual rhythm.

• The Meeting Place
A distraction-free prayer experience with optional silent presence mode.

• Verse Actions
Highlight verses, add notes, and mark passages to pray over later.

• Prayer Tracking
Keep a personal record of prayers and celebrate answered prayers in the "Remembered" section.

• Prayer Alarms
Set gentle reminders for your prayer times with customizable snooze options.

• Customization
Choose your flame color theme, adjust reading fonts, and personalize your experience.

PRIVACY FIRST

All your data stays on your device. No accounts required. No tracking. No sharing. Your spiritual journey is between you and God.

WHAT MAKES THIS DIFFERENT

The Altar doesn't change you—God will. This app simply provides a quiet, grace-filled space to spend time with Him.

No streaks to maintain. No trophies to earn. No pressure to perform. Just invitation.

ATTRIBUTION

Scripture content provided by API.Bible (scripture.api.bible)
```

---

### 20. Prepare Promotional Text (Optional)
**Character Limit:** 170 characters

**Example:**
```
A grace-centered space for prayer and Bible reading. No performance pressure. No tracking. Just you and God. All data stays on your device.
```

---

### 21. Keywords
**Character Limit:** 100 characters (includes commas)

**Recommended:**
```
prayer,bible,devotional,scripture,christian,faith,quiet time,spiritual,KJV,worship
```

**Tips:**
- Don't include app name (automatically indexed)
- Focus on how users search
- Separate with commas, no spaces
- Avoid competition (don't include other app names)

---

### 22. Review Notes for Apple
**Provide Context:**

```
App Review Team,

The Altar is a Christian prayer and Bible reading application with the following technical details:

1. BIBLE CONTENT: We use API.Bible (scripture.api.bible) for scripture text. The embedded API key is live, active, and functional. No additional credentials are needed to test Bible reading features.

2. LOCAL-FIRST DESIGN: All user data is stored locally on device using UserDefaults. There is no server backend, no authentication system, and no network calls except to API.Bible for scripture content.

3. NOTIFICATIONS: Prayer alarms use the standard UNUserNotificationCenter framework. Authorization is requested after onboarding is complete.

4. PRIVACY: We do not collect any personal information, use analytics, or track users. The app is designed to be completely private and local to the user's device.

5. TESTING: To fully test the app, please:
   - Complete the 7-step onboarding flow
   - Navigate to the "Read" tab to access Bible content
   - Create a prayer commitment in the "Pray" tab
   - Set a test alarm in Settings > Prayer Alarms

Thank you for reviewing The Altar. We're committed to providing a high-quality, privacy-respecting spiritual growth tool.

Contact: [YOUR EMAIL]
Phone: [YOUR PHONE]
```

---

## FINAL VERIFICATION

### Pre-Submission Checklist

**Build Verification:**
- [ ] Clean build succeeds (Cmd+Shift+K, then Cmd+B)
- [ ] No compiler warnings
- [ ] App runs on iOS 17 simulator
- [ ] App runs on iOS 18 simulator
- [ ] Archive builds successfully (Product > Archive)

**Feature Testing:**
- [ ] Complete onboarding flow
- [ ] Read Bible chapter (online)
- [ ] Read Bible chapter (offline/cached)
- [ ] Create prayer commitment
- [ ] Start and complete prayer session
- [ ] Set and receive prayer alarm
- [ ] Change settings (font size, theme)
- [ ] Add verse highlights
- [ ] Add prayer notes
- [ ] Mark prayer as answered

**Compliance Verification:**
- [ ] Privacy Manifest included in build
- [ ] Location permission removed
- [ ] API.Bible attribution visible in app
- [ ] Privacy policy URL accessible
- [ ] Support URL accessible
- [ ] All screenshots uploaded
- [ ] App description complete
- [ ] Keywords optimized
- [ ] Review notes written

**Post-Archive:**
- [ ] Validate archive (Xcode > Organizer)
- [ ] Upload to App Store Connect
- [ ] Select build in App Store Connect
- [ ] Submit for review
- [ ] Monitor email for review updates

---

## ESTIMATED TIMELINE

**Day 1 (4-6 hours):**
- Tasks 1-6: Critical fixes and privacy

**Day 2 (3-4 hours):**
- Tasks 7-10: High priority items

**Day 3 (4-6 hours):**
- Tasks 11-14: Testing and verification

**Day 4 (2-3 hours):**
- Tasks 18-22: App Store Connect setup

**Day 5 (2-3 hours):**
- Final verification and submission

**Total: 15-22 hours over 5 days**

---

## SUCCESS METRICS

**App Review Timeline:**
- Submission to "In Review": 1-2 days
- "In Review" to decision: 1-3 days
- Total: 2-5 days typically

**Common Metadata Rejections (Easy to Fix):**
- Screenshot text too small
- Description contains competitor mentions
- Privacy policy link broken
- Missing required keywords

**App Rejections (Requires Resubmission):**
- Missing privacy manifest (FIXED if you complete Task #1)
- Unused permissions (FIXED if you complete Task #2)
- Incomplete features (unlikely - your app is complete)

---

## SUPPORT

**Questions During Implementation?**
Refer to:
- Full audit report: `APP_STORE_COMPLIANCE_AUDIT.md`
- Apple Developer Forums: developer.apple.com/forums
- API.Bible Documentation: scripture.api.bible/docs

**After Submission:**
- Monitor App Store Connect email notifications
- Respond to reviewer questions within 24 hours
- Be prepared to provide additional information if requested

---

**Good luck with your submission!**

The Altar is a well-built app with strong fundamentals. Following this checklist will maximize your chances of first-submission approval.
