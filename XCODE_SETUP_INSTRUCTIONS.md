# Xcode Project Setup Instructions

## Step 1: Open Project in Xcode

1. Navigate to `/Users/oliyaddeyasa/Desktop/The Alter beta 2/`
2. Double-click `The Alter beta 2.xcodeproj` to open in Xcode

---

## Step 2: Remove Old File References

In the Xcode file navigator (left sidebar), remove these files (they'll show as red/missing):

### Files to DELETE from project:
- `The_Alter_beta_2App.swift` (old app file)
- `DataStore.swift` (old data store)
- Any other red/missing file references

**How to remove:**
1. Right-click the file in Xcode
2. Select "Delete"
3. Choose "Move to Trash" (or "Remove Reference" if you want to keep the files)

---

## Step 3: Add New Files to Project

### Method: Drag and Drop (Easiest)

1. In Finder, navigate to `/Users/oliyaddeyasa/Desktop/The Alter beta 2/The Alter beta 2/`
2. In Xcode, select the "The Alter beta 2" folder in the left sidebar
3. Drag these files/folders from Finder into Xcode:

#### Core Files:
- `TheAltarApp.swift` ✨ (New main app file)
- `AppDataStore.swift` ✨
- `ContentView.swift` ✨

#### Models Folder:
- Drag the entire `Models/` folder
- Files inside:
  - `User.swift` ✨
  - `IdentityClass.swift` ✨
  - `CommitmentProfile.swift` ✨
  - `BibleProgress.swift` ✨
  - `VerseAction.swift` ✨
  - `PrayerSession.swift` ✨
  - `PrayerItem.swift` ✨
  - `DailyMetrics.swift` ✨
  - `BibleModels.swift` ✨
  - `Models.swift` (already exists - Alarm/Reminder)

#### Services Folder:
- Drag the entire `Services/` folder
- File inside:
  - `BibleCalculator.swift` ✨

#### Managers Folder (Update existing):
- The folder already exists with 3 files
- Add new file:
  - `BibleAPIManager.swift` ✨

#### Views Folder:
- Drag the entire `Views/` folder
- Folders inside:
  - `Onboarding/` (OnboardingViews.swift, OnboardingViews2.swift) ✨
  - `Home/` (HomeView.swift) ✨
  - `Bible/` (BibleViews.swift) ✨
  - `Prayer/` (PrayerViews.swift) ✨
  - `Settings/` (SettingsView.swift - already exists)
  - `Alarms/` (AlarmsView.swift, RemindersView.swift - already exist)

**When dragging:**
- ✅ CHECK "Copy items if needed"
- ✅ CHECK "Create groups" (not folder references)
- ✅ CHECK "Add to targets: The Alter beta 2"

---

## Step 4: Update API Key

1. Open `Managers/BibleAPIManager.swift` in Xcode
2. Find line 8:
   ```swift
   private let apiKey = "YOUR_API_KEY_HERE"
   ```
3. Replace with your API key from https://scripture.api.bible/
4. Register for free account → Get API key → Paste it

---

## Step 5: Build Project

1. Select target device: **Any iOS Device** or a simulator
2. Press **Cmd+B** to build
3. Fix any errors that appear (usually import/reference issues)

### Common Build Errors & Fixes:

**Error: "Cannot find 'X' in scope"**
- Solution: Make sure all files are added to the target (check Step 3)

**Error: "Multiple commands produce..."**
- Solution: Remove duplicate file references

**Error: "No such module 'X'"**
- Solution: Clean build folder (Cmd+Shift+K) and rebuild

---

## Step 6: Run the App

1. Press **Cmd+R** to run
2. The app should launch showing the onboarding flow
3. Complete onboarding to test the full app

---

## Step 7: Test Checklist

After the app builds successfully, test:

- [ ] Onboarding flow (7 steps)
- [ ] Home view shows commitment
- [ ] Bible reading (requires API key)
- [ ] Prayer (The Meeting Place)
- [ ] Silent Presence Mode
- [ ] Add prayer items
- [ ] Mark prayers as answered
- [ ] Alarms
- [ ] Settings
- [ ] Edit commitment

---

## Troubleshooting

### If Build Fails:

1. **Clean Build Folder**: Product → Clean Build Folder (or Cmd+Shift+K)
2. **Delete Derived Data**:
   - Xcode → Settings → Locations
   - Click arrow next to Derived Data path
   - Delete the folder for this project
3. **Restart Xcode**
4. **Rebuild**: Cmd+B

### If App Crashes:

1. Check console for error messages
2. Verify all @EnvironmentObject dependencies are provided
3. Check that AppDataStore is properly initialized in TheAltarApp

### If Files Are Missing:

Run this command in Terminal to list all Swift files:
```bash
find "/Users/oliyaddeyasa/Desktop/The Alter beta 2/The Alter beta 2" -name "*.swift" -type f
```

---

## File Structure Reference

After adding all files, your project should look like this in Xcode:

```
The Alter beta 2/
├── TheAltarApp.swift ✨
├── AppDataStore.swift ✨
├── ContentView.swift ✨
├── Theme.swift
├── ErrorHandling.swift
├── Intents.swift
├── Notifications+Intents.swift
├── Models/
│   ├── Models.swift (Alarm, Reminder)
│   ├── User.swift ✨
│   ├── IdentityClass.swift ✨
│   ├── CommitmentProfile.swift ✨
│   ├── BibleProgress.swift ✨
│   ├── VerseAction.swift ✨
│   ├── PrayerSession.swift ✨
│   ├── PrayerItem.swift ✨
│   ├── DailyMetrics.swift ✨
│   └── BibleModels.swift ✨
├── Services/
│   └── BibleCalculator.swift ✨
├── Managers/
│   ├── HapticManager.swift
│   ├── NotificationManager.swift
│   ├── AlarmRingerManager.swift
│   └── BibleAPIManager.swift ✨
└── Views/
    ├── Onboarding/
    │   ├── OnboardingViews.swift ✨
    │   └── OnboardingViews2.swift ✨
    ├── Home/
    │   └── HomeView.swift ✨
    ├── Bible/
    │   └── BibleViews.swift ✨
    ├── Prayer/
    │   └── PrayerViews.swift ✨
    ├── Settings/
    │   └── SettingsView.swift
    └── Alarms/
        ├── AlarmsView.swift
        └── RemindersView.swift
```

✨ = New file created in rebuild

---

## Next Steps After Successful Build

1. **Get API.Bible Key**: https://scripture.api.bible/
2. **Test all features**: Go through checklist above
3. **Add app icon**: Assets.xcassets
4. **Update bundle identifier**: Project settings
5. **Prepare for TestFlight**: When ready for submission

---

## Need Help?

If you encounter issues:
1. Check the REBUILD_SUMMARY.md for architecture details
2. Verify file paths match exactly
3. Ensure all files have correct targets checked
4. Look at Xcode build errors for specific file/line issues

**The app is now ready to build!** 🎉
