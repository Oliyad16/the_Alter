


# 🔧 DEVELOPMENT.md – The Alters iOS App

> This file contains detailed technical specifications for the implementation of **The Alters**, a spiritual prayer companion app. It outlines each screen, user flow, logic, design elements, and system architecture according to Apple’s best practices and HIG.

---

## 📱 App Architecture

- **Language**: Swift 5+
- **Framework**: SwiftUI (preferred), Combine, CoreData
- **Pattern**: MVVM (Model-View-ViewModel)
- **Target**: iOS 15+

---

## 📂 Folder Structure

/TheAlters
├── App/                      # App entry point (AppDelegate, Scenes)
├── Views/                    # SwiftUI Screens
│   ├── Home/
│   ├── Prayer/
│   ├── Log/
│   ├── Stats/
│   └── Settings/
├── ViewModels/               # View logic & state
├── Models/                   # Data models (Prayer, AltarStone, etc.)
├── Services/                 # Alarm manager, Storage, Notifications
├── Assets.xcassets/          # Icons, Colors, Symbols
├── Resources/                # Fonts, Localizations
├── Extensions/               # Reusable Swift extensions
└── Utils/                    # Helpers, Enums, Constants

---

## 🔄 Navigation Map

[Home]
├──> Start Prayer (→ [Prayer Timer])
├──> Prayer Log (→ [Log])
├──> Stats (→ [Stats])
└──> Settings (→ [Settings])

---

## 📄 Screens & Components

### 🔥 1. Home Screen (`Views/Home/HomeView.swift`)

#### Purpose:
Central hub where user is invited into prayer.

#### Components:
- Greeting: “Welcome back, [Name]”
- Current Flame Status: Visual (growing/dimming fire)
- Buttons:
  - “🔥 Ignite Prayer”
  - “📖 My Altar Stones”
  - “📊 Stats”
- Optional Daily Verse (fades in)

#### Design:
- Dark background (#0A0A0A)
- Glowing flame animation
- SF Symbol for fire: `flame.fill`

#### Logic:
- Uses AppState to show streaks, total minutes today
- Fetches latest active prayer points for preview

---

### ⏱️ 2. Prayer Timer Screen (`Views/Prayer/PrayerView.swift`)

#### Purpose:
Allows users to time and focus their prayer session.

#### Components:
- Fire Circle Countdown (animated)
- Optional Music Picker (Soaking, Warfare, Healing, Silence)
- Background Audio Player (if selected)
- “End Session” Button

#### UI States:
- `Idle`, `Praying`, `Completed`

#### Features:
- When session ends:
  - Duration saved
  - Encouragement message shown: “🔥 Your altar burned for 20 minutes.”

#### Logic:
- Uses `PrayerTimerViewModel` for time handling
- Music streamed from local bundle or URL
- Saves session to CoreData

---

### 📔 3. Prayer Log (Altar Stones) (`Views/Log/LogView.swift`)

#### Purpose:
Displays user's prayer points as glowing altar stones.

#### Components:
- Scrollable list of Prayer Points
- Each Point displays:
  - Title
  - Status: 🔴 Active | ✨ Answered | ⚫ Rejected
  - Created & Last Prayed
- “+ New Prayer” button

#### Add/Edit Modal:
- Input: Title, Category, Description
- Tags (e.g. Healing, Family)
- Save to CoreData

#### Visuals:
- Stones glow red, gold, or grey
- Grid layout
- Tap → expand for full prayer + journal notes

#### Logic:
- All data persists with CoreData
- Sorted by date created or last prayed
- Filters: Status, Category, Tag

---

### 📊 4. Stats Screen (`Views/Stats/StatsView.swift`)

#### Purpose:
Visual dashboard of user’s spiritual growth.

#### Components:
- Total Time Prayed (Day/Week/Month)
- Avg. Prayer Duration
- Streak Counter
- Fire Animation:
  - 🔥 Growing = consistent prayer
  - ⚠️ Dimming = inconsistent

#### Charts:
- Line chart for past 7 days
- Flame scale animation (small to large)

#### Trophies:
- List of unlocked milestones:
  - Spark (3 Days) – Zech. 4:10
  - Kindled Flame (7 Days) – Lev. 6:13
  - Consuming Fire (30 Days) – Heb. 12:29

#### Logic:
- Calculates streak from `PrayerSession` model
- Uses date math to render flames
- Trophy badge system w/ optional haptics

---

### ⚙️ 5. Settings Screen (`Views/Settings/SettingsView.swift`)

#### Purpose:
User preferences, notifications, music options, backup/export.

#### Components:
- 🔔 Alarm Settings
  - Add/Delete Prayer Times
  - Custom labels: “Morning Devotion”, “Midday Praise”
  - Notification sounds
- 🎶 Music Volume
- 🌑 Dark/Light Mode toggle
- 🔄 Export Prayer Log (PDF, JSON)
- 🔒 Privacy Policy / App Info

#### Logic:
- Uses `AlarmService` to register local notifications
- Saves settings to `UserDefaults`
- Allows iCloud export (Phase 2)

---

## 📦 Models

### PrayerPoint

```swift
struct PrayerPoint: Identifiable, Codable {
  var id: UUID
  var title: String
  var category: String
  var description: String
  var status: PrayerStatus
  var createdAt: Date
  var updatedAt: Date
}
enum PrayerStatus: String, Codable {
  case active, answered, rejected
}

PrayerSession

struct PrayerSession: Identifiable, Codable {
  var id: UUID
  var startTime: Date
  var duration: TimeInterval
  var musicType: MusicCategory
}


⸻

🔔 Alarm System (Local Notification Logic)

Flow:
	•	User adds alarm → Time saved to UserDefaults + UNUserNotificationCenter
	•	On trigger:
	•	Prompt screen shows:
	•	✅ Start Prayer
	•	⏳ Snooze (limit 2x)
	•	❌ Reject Prayer
	•	All actions tracked

Code Snippet:

let content = UNMutableNotificationContent()
content.title = "Time to pray"
content.body = "Will you ignite your altar or let it burn out?"
content.sound = .default


⸻

📖 AI Prayer Deepener (Phase 2)

Flow:
	1.	User enters vague prayer (e.g. “I need money”)
	2.	AI asks:
	•	“Why?” → “To pay rent”
	•	“How?” → “Job or business?”
	•	“What gifts has God given you?”
	3.	Breakdown:
	•	Mini-Prayers (e.g. “Wisdom to build resume”)
	•	Scriptures (e.g. James 1:5)
	•	Suggested Actions

LLM Integration:
	•	On-device CoreML (optional)
	•	Remote GPT via OpenAI or local API
	•	User privacy respected — optional toggle

⸻

🎨 Design Best Practices
	•	Minimize UI chrome — focus on the flame, text, and stones
	•	Use SF Symbols (flame.fill, circle.grid.3x3.fill, etc.)
	•	Use system colors & adaptive spacing for Dynamic Type
	•	Animate with withAnimation and matchedGeometryEffect
	•	Tap areas ≥ 44pt

⸻

🧪 Testing
	•	XCTest for:
	•	Prayer Timer
	•	Prayer Data Store
	•	Notification Manager
	•	UI Testing with:
	•	Tap sequences
	•	Accessibility
	•	Dark mode
	•	iPhone SE → iPhone 15 Pro Max

⸻

🌐 Roadmap Snapshot

Phase	Feature	Status
MVP	Home, Timer, Log, Stats, Settings	✅ Done
V2	AI Prayer Deepener	🔄 In Dev
V3	Global Prayer Rooms	🔜 Planned
V4	Sync across devices, iCloud	🔜 Planned


⸻

📚 References
	•	Swift Documentation
	•	Human Interface Guidelines
	•	CoreData Guide
	•	UNNotificationCenter Guide

⸻

For questions, contributions, or to join the mission of helping believers build a consistent altar of prayer — contact: info@thealters.app
