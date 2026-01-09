# 🎨 UX/UI DESIGN SPEC — The Alters 🔥  
*“Let the fire on the altar never go out.” — Leviticus 6:13*

---

## 🧭 Final Navigation (4 Pages Only)

| Page               | Icon               | Description                                                                 |
|--------------------|--------------------|-----------------------------------------------------------------------------|
| 🔥 Home             | `flame.fill`        | Central altar hub + flame streak + stats + scripture + reward progression  |
| ⏱ Prayer Timer      | `clock.fill`        | Immersive countdown + fire visuals + prayer music + encouragement           |
| 📖 Altar Log         | `book.fill`         | Glowing stones representing prayer points (active, answered, rejected)     |
| ⚙️ Settings          | `gearshape.fill`    | Alarms, themes, preferences, sounds, export, app info                      |

---

# 🔥 1. Home Page — *The Living Altar*

### Purpose:
This is your sacred dashboard. It visually reflects how "alive" the user's altar is based on their prayer life. Stats and rewards are merged here for one powerful, soul-stirring home.

### Visual Layout:

[ 🔥 Glowing Animated Flame Icon ] (resizes based on streak)

👤 Welcome back, Oliyad.
🔥 Your altar is burning strong.
📅 Streak: 7 days
⏱ Today: 20m | Week: 1h 10m

[ ✅ Ignite Prayer Now ]
[ 📖 View Altar Stones ]
[ 🏆 View Rewards Progress ]

📜 Scripture of the Day:
“Be joyful in hope, patient in affliction, faithful in prayer.” — Romans 12:12

### Features:
- **Live Flame Animation**: Grows brighter & bigger as streak increases.
- **Stats Summary**: Embedded visually into the flame section.
- **Quick Actions**: Access Prayer, Altar Log, or Rewards quickly.
- **Scripture Tile**: Daily verse fades in; tap to expand and share.

### Emotional Design:
- Visual affirmation (“🔥 Your altar is blazing!”)
- Sound: soft flame crackle on idle, warm wind on scroll
- Gentle nudge if you skip a day: “Don't let the fire go out.”

---

# ⏱ 2. Prayer Timer Page — *Ignite the Fire*

### Purpose:
Help users pray without distraction using a focused visual countdown experience.

### Visual Layout:

[ 🔥 Animated Fire Ring Countdown: 20:00 ]
(Subtle glow pulses in sync with time)

Controls:
⏸ Pause     🔊 Music Picker     ✅ End

[ 🎶 Music: Soaking | Warfare | Silence ]

### Features:
- **Fire Ring Timer**: A circular glowing ring that “burns” as time passes
- **Music Picker**: Choose from curated instrumental backgrounds
- **Session End Message**:  
  “🔥 You kept the altar burning for 22 minutes today. Well done.”
- **Auto-save**: Duration stored in CoreData + affects streak

### Micro UX:
- Haptic vibration on start
- Music fades in with incense/sparkle animation
- “Ignite Now” tap gives a satisfying spark + sound

---

# 📖 3. Altar Log — *Memory of Prayers*

### Purpose:
Visualize the user's prayer journey using altar stones (active, answered, abandoned).

### Visual Layout:

[ Grid of Stones ]
🔴 Healing Mom  (Active)
✨ New Job      (Answered)
⚫ Old Habit    (Rejected)

[ ➕ Add New Prayer ]

### Stone States:
- 🔴 **Active**: Glowing red stone with pulse
- ✨ **Answered**: Gold sparkle + date answered
- ⚫ **Rejected**: Ash-grey cracked stone

### Features:
- Tap = View prayer + journal
- Long Press = Change state
- “+” Button = Add new prayer with:
  - Title, Category, Notes, Tags
  - Set Intention: (Faith, Breakthrough, Guidance, etc.)

### Animations:
- Answered: sparkles rise like incense
- Rejected: ember crack & fade

---

# ⚙️ 4. Settings Page — *Tune the Rhythm of Your Altar*

### Purpose:
Let users fine-tune their altar experience.

### Sections:

#### 🔔 Prayer Reminders
- Add/Edit/Delete prayer alarms
- Custom labels: “Morning Fire,” “Evening Watch”
- Ringtone & Vibration options
- Max 3 snoozes per prayer time

#### 🎵 Music Preferences
- Default background (Soaking, Warfare, Healing)
- Volume Slider

#### 🎨 Appearance & Theme
- Dark/Light toggle
- Option: Dim screen during prayer session
- Turn off flame animation (for battery)

#### 🔐 Data & Privacy
- Export log (PDF or JSON)
- Reset all app data
- App version & support link

#### 🧼 Do Not Disturb Mode
- When in session, silence notifications
- Auto-DND with timer toggle

---

# 🏆 Gamified Rewards — *Spiritual Milestones*

> Prayer isn’t about performance — but consistency builds fire.  
> These are **rewards from Scripture**, not dopamine tricks.

### Trophy Progression:

| Name              | Streak Required | Visual      | Scripture                                    |
|-------------------|------------------|-------------|----------------------------------------------|
| **Spark**         | 3 Days           | 🔅           | Zech. 4:10 – “Do not despise small beginnings.” |
| **Kindled Flame** | 7 Days           | 🔥           | Lev. 6:13 – “The fire must be kept burning.” |
| **Consuming Fire**| 30 Days          | 🔥🔥🔥        | Heb. 12:29 – “Our God is a consuming fire.”  |
| **Flame of Fire** | Special          | 🕊🔥👑        | Heb. 1:7 – “He makes His ministers flames of fire.” |

### Unlock Effects:
- Unique animations
- Scripture meditations unlocked
- Celebration sound + firework spark

---

# 🎨 Visual & Motion Design

### Colors
| Name               | Hex         | Usage                            |
|--------------------|-------------|----------------------------------|
| Fiery Red          | `#FF3B30`   | Action, Active Stones, Timers    |
| Gold (Answered)    | `#FFD700`   | Rewarded prayers, trophies       |
| Ash Grey           | `#4A4A4A`   | Rejected prayers, inactive logs |
| Sacred Black       | `#0A0A0A`   | Background, base of altar        |
| Night Blue         | `#1C1C2E`   | Dim overlays, modals             |

### Fonts
- **Headlines**: SF Pro Rounded Bold
- **Body Text**: SF Pro Regular
- Scales with Dynamic Type

### Motion
- `matchedGeometryEffect` for seamless page transitions
- Fire particles: subtle embers float upward
- All taps: ripple glow + haptic light feedback

---

# 🔈 Sound UX (Optional)

| Action                   | Sound Effect               |
|--------------------------|----------------------------|
| Start Prayer             | Whisper: “Ignite…” + spark |
| End Prayer Session       | Soft wind whoosh           |
| Trophy Unlocked          | Chime + firework pop       |
| Reject Prayer            | Ember crackle              |

---

# ✅ Accessibility Features

- Dynamic Type across all text
- VoiceOver for all controls and visuals
- High Contrast Mode support
- Reduce Motion toggle disables ember animations
- Haptics are optional and user-controllable

---

# 🔮 Hidden Delights (User Surprise)

- **New Day?**: “🔥 A new day. A new fire to light.”
- **Rainy Day Theme** (optional): raindrops on altar flame
- **Tap-and-Hold Flame on Home**: Secret verse unlocks (“🔥 Hidden in the fire...”)

---

# 📎 Summary

**The Alters** is a sacred app experience — minimal, beautiful, and intentionally holy.

- 💡 4 Pages only
- 🔥 Every page = an extension of the altar
- 🧠 Merges Apple’s best UX/UI practices with spiritual symbolism
- ✨ Rewards grounded in Scripture, not addiction

> “He makes His ministers flames of fire.” — Hebrews 1:7

---

📐 Would you like this turned into:
- A **Figma prototype**?
- A **SwiftUI component kit**?
- A **Clickthrough iOS Playground demo**?

Let me know — this altar is ready to be built.