# Smart Alarm App — Design Document
**Codename:** HereBuzzer  
**Version:** 1.0  
**Date:** 2026-02-17

---

## 1. Overview

HereBuzzer is a location-aware alarm app that ensures your alarm only rings when you're near a geofenced location (e.g., home), with flexible dismissal methods and smart snooze behaviors.

---

## 2. Core Features

### 2.1 Location-Aware Alarming

| Feature | Description |
|---------|-------------|
| **Geofence Target** | User sets a target location (address or GPS coordinates) |
| **Trigger Radius** | Configurable distance (default: 100m, range: 10m - 2km) |
| **Ring Condition** | Alarm ONLY fires if: (time reached) AND (device is within target radius) |
| **Arrival Detection** | Background geolocation polling every 30-60 sec when alarm is armed |

**Edge Cases:**
- User enters zone after alarm time passed? → Trigger immediately upon entry
- User never enters zone? → Optional: ring anyway after grace period (configurable 15-60 min)
- GPS accuracy issues? → Use fuzzy match (+/- 50m tolerance)

---

### 2.2 Shake to Snooze

| Property | Value |
|----------|-------|
| **Trigger** | Accelerometer detects shake motion |
| **Sensitivity** | Medium (filter out accidental bumps) |
| **Action** | Silences audio for 10 seconds only |
| **Repeat** | Can be used multiple times; does NOT snooze the alarm off |

**Implementation Notes:**
- Use Gyroscope + Accelerometer for better motion detection
- Ignore slow/tilt movements (< 3g acceleration)
- Visual feedback: brief vibration + screen flash when triggered

---

### 2.3 QR Code Dismissal (Optional)

| Feature | Description |
|---------|-------------|
| **Enable Per-Alarm** | User toggles QR mode on/off per alarm |
| **Setup Flow** | Generate / Scan a QR code to bind to the alarm |
| **Dismiss Action** | Open camera → scan matching QR → alarm stops |
| **Fallback** | Standard dismiss button always available (can't get trapped) |

**Use Cases:**
- Put QR in another room to force getting up
- Pair with bathroom mirror or kitchen fridge

---

### 2.4 Recurring Schedule

| Property | Options |
|----------|---------|
| **Time** | HH:MM (24h format) |
| **Days** | Multi-select: Mon, Tue, Wed, Thu, Fri, Sat, Sun |
| **One-Time Alarms** | Enable single occurrence option |
| **Active/Inactive** | Toggle alarm on/off without deleting |

---

### 2.5 Self-Destruct on Dismissal (Optional)

| Feature | Description |
|---------|-------------|
| **Enable Per-Alarm** | User toggles "Delete after dismissal" per alarm |
| **Trigger** | Alarm is permanently deleted after: full dismissal (NOT shake snooze) |
| **Confirmation** | Optional: show brief toast "Alarm deleted" on dismiss |
| **Exclusions** | Does NOT delete if: dismissed by shake, snoozed, or force-stopped |

**Use Cases:**
- One-off reminders ("Pick up dry cleaning today") — useful as a quick reminder alarm
- Temporary alarms you don't want cluttering your list
- Ad-hoc alarms during travel or irregular schedules

**Edge Cases:**
- App killed before delete operation completes? → Re-check and cleanup on next app launch
- Dismissed while offline? → Queue deletion for next sync/launch

---

### 2.6 Custom Ringtones & Recording

| Feature | Description |
|---------|-------------|
| **Preset Ringtones** | Built-in library of alarm sounds (classic, nature, musical, etc.) |
| **Device Audio** | Import from phone's music/audio files (MP3, M4A, WAV, OGG) |
| **Record Custom** | In-app voice recorder to create personal alarm messages |
| **Per-Alarm Assignment** | Each alarm can have its own unique ringtone |
| **Volume Curve** | Optional fade-in (starts quiet, ramps up over 5-15 seconds) |

**Recording Specifications:**
- **Format**: AAC or WAV
- **Max Duration**: 30 seconds
- **Quality**: 44.1kHz, mono (sufficient for alarms)
- **Storage**: Saved to app-private directory

**Use Cases:**
- Record your own voice: "Wake up Jade, it's gym day!"
- Record kids saying good morning
- Custom reminders: "Don't forget your presentation today"
- Favorite song snippets from your library

**UI Flow:**
1. Tap "Ringtone" in alarm settings
2. **Tabs**: [Presets] [My Recordings] [Device Audio]
3. **Presets**: Grid of playable samples
4. **My Recordings**: List + "Record New" button with waveform preview
5. **Device Audio**: File browser/filter for audio files
6. All choices show "Play Preview" before confirming

**Edge Cases:**
- Deleted source file? → Fall back to default ringtone + notification
- Corrupted recording? → Alert user, offer re-record
- Storage full? → Compress older recordings, prompt to delete
- Microphone permission denied? → Guide to settings, disable recording option

---

## 3. Data Models

```json
{
  "Alarm": {
    "id": "uuid",
    "name": "string (optional)",
    "time": "07:30",
    "days": ["mon", "tue", "wed", "thu", "fri"],
    "isEnabled": true,
    "isLocationAware": true,
    "targetLocation": {
      "latitude": 45.523064,
      "longitude": -122.676483,
      "address": "123 Main St",
      "radiusMeters": 100
    },
    "qrDismiss": {
      "enabled": false,
      "qrData": "base64-encoded-qr-content"
    },
    "ringtone": "default|custom_uri",
    "volume": 0.8,
    "vibrate": true,
    "gracePeriodMinutes": 30
  }
}
```

---

## 4. Screens & UI Flow

### Screen 1: Alarm List (Home)
- List of all alarms with toggle switches
- Shows: Time, Days (Mon-Fri etc.), Location status icon
- FAB to create new alarm
- Edit / Delete via swipe/long-press

### Screen 2: Create/Edit Alarm
1. **Set Time** — Time picker (wheel or dial)
2. **Repeat Schedule** — Day toggle chips (M T W T F S S)
3. **Location Mode** — Toggle "Only ring when I'm near..."
   - If ON: Search/Map to set target location + radius slider
4. **Dismiss Method** — Toggle "Require QR code scan" (with preview/test)
5. **Sound & Volume** — Ringtone picker + volume slider
6. **Label** — Optional name ("Work Alarm", "Gym Day")

### Screen 3: Active Alarm (Foreground)
- Large time display
- Shake animation indicator
- QR Camera button (if enabled)
- Standard "Dismiss" button
- 10-sec countdown if snoozed

---

## 5. Technical Architecture

### Permissions Required
| Permission | Purpose |
|------------|---------|
| `ACCESS_FINE_LOCATION` | Precise geofencing |
| `ACCESS_BACKGROUND_LOCATION` | Monitor entry/exit when app closed |
| `CAMERA` | QR code scanning |
| `VIBRATE` | Haptic feedback |
| `WAKE_LOCK` | Keep screen on during alarm |
| `FOREGROUND_SERVICE` | Reliable location updates |
| `POST_NOTIFICATIONS` | Alarm notification |

### Background Services

```
┌─────────────────────────────────────────┐
│         AlarmManager (System)           │
│     Triggers at scheduled times         │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      Geofence Check Service             │
│  - Check if within target radius        │
│  - If YES: Trigger AlarmActivity          │
│  - If NO: Set grace period timer        │
└─────────────────────────────────────────┘
```

### Shake Detection (Pseudocode)

```kotlin
// Accelerometer threshold values
val SHAKE_THRESHOLD = 800
val SHAKE_TIMEOUT = 500ms

onSensorChanged(event) {
    val speed = sqrt(x² + y² + z²) - gravity
    if (speed > SHAKE_THRESHOLD && now - lastShake > SHAKE_TIMEOUT) {
        triggerTemporarySilence(10.seconds)
        lastShake = now
    }
}
```

### QR Code Handling

- Library recommendation: ML Kit (Android) / AVFoundation (iOS)
- Store SHA256 hash of QR data, not raw content (security)
- Support print/export QR for placing around house

---

## 6. Settings & Configuration

| Setting | Default | Options |
|---------|---------|---------|
| Snooze Duration | 10 min | 5, 10, 15, 20 min |
| Grace Period | 30 min | Off, 15, 30, 45, 60 min |
| Shake Sensitivity | Medium | Low, Medium, High |
| GPS Update Interval | 60 sec | 30, 60, 120 sec |
| Default Radius | 100 m | 10-2000 m |
| Max Volume Override | On | On / Off |

---

## 7. Notifications & State

| State | User Notification |
|-------|-------------------|
| Alarm Armed | "Alarm set for 7:30 AM near Home" |
| Entered Zone | "You're near your alarm location" (optional) |
| Alarm Firing | Full-screen + sound + vibration |
| Grace Period End | "You missed your location. Alarm ringing now" |
| QR Dismissed | "Alarm dismissed via QR scan" |

---

## 8. Edge Cases & Error Handling

| Scenario | Handling |
|----------|----------|
| GPS disabled at alarm time | Ring immediately (fail-safe) + show warning |
| Location permission revoked | Prompt to re-enable; alarm reverts to time-only |
| Battery optimization kills background service | Request battery whitelist on setup |
| Two overlapping alarms | Queue them; fire sequentially |
| Device reboot | Re-register all alarms via `BOOT_COMPLETED` receiver |
| Timezone change | Auto-adjust alarm times to new local time |

---

## 9. Future Enhancements (v2 Ideas)

- Sleep tracking integration (smart wake within 30-min window)
- Multiple location profiles (home/work/gym)
- NFC tag dismissal option
- Weather-aware snooze (rain = extra 10 min?)
- Task-based dismissal (solve math problem)
- Smart watch integration

---

## 10. Open Questions

1. **iOS Implementation:** iOS background location restrictions may require significant adaptation
2. **Battery Impact:** Background geofencing trade-offs need testing
3. **Wear OS:** Should companion watch app mirror shake behavior?
4. **Cloud Sync:** Save alarms across devices or local-only?

---

*Document ready for development kickoff.*
