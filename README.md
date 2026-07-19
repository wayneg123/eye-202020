# EyeBreak 20-20-20

A native macOS menu-bar app for the 20-20-20 rule: every 20 minutes of screen time, look ~20 feet away for 20 seconds.

Available in English (default) and Simplified Chinese. Switch anytime with the in-app `中/En` control; the choice is saved on device.

## Features

- Menu bar countdown plus a full dashboard window
- System notifications and a floating break panel that shows across Spaces
- Custom work duration, viewing distance, and break length
- Five-minute snooze, end-early, and skip
- Daily summary, seven-day trends, and completion streaks
- Cycle resets after screen lock, sleep, or display sleep
- Launch at login, optional notification sounds, local-only storage
- Full EN / 简体中文 coverage (UI, notifications, accessibility labels)

## How Codex & GPT-5.6 were used

Codex worked against the real Swift tree: mapping the dependency graph, turning requirements into scoped edits, building the bilingual localization layer, touching every user-facing string surface, running XCTest, and checking the built app.

The useful part of GPT-5.6 was debugging, not boilerplate. Idle CPU was stuck around ~24% because a one-second global clock and a looping progress-ring animation kept SwiftUI rebuilding too much UI. We narrowed updates to small `TimelineView` subtrees; idle usage dropped under 1% with the countdown still correct. Product decisions, naming, tone, and acceptance criteria stayed human-owned; the models sped up implementation, diagnosis, docs, and verification.

## Requirements

- macOS 14 or later
- Full Xcode (Command Line Tools alone cannot build the `.app`)

Open `Eye202020.xcodeproj`, select the `Eye202020` scheme, press `⌘R`. Notification permission is requested on first launch; the break window still works if notifications are denied.

## Testing

In Xcode: `⌘U`, or:

```sh
xcodebuild test -project Eye202020.xcodeproj -scheme Eye202020 -destination 'platform=macOS'
```

Settings and statistics live in `UserDefaults` only.

## Visual assets

- `Design/AppIcon.svg` — editable vector source for the app icon
- Break-window mountain landscape — created with OpenAI image generation; original bitmap in this repo
