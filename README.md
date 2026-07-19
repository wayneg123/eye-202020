# EyeBreak 20-20-20

EyeBreak 20-20-20 is a native macOS eye-care reminder that helps people follow the 20-20-20 rule: after 20 minutes of screen work, look at something 20 feet (about 6 meters) away for 20 seconds.

The app is available in English and Simplified Chinese. English is the default language; users can switch instantly with the in-app `中/En` control, and their choice is saved locally.

## Features

- Menu bar countdown and a full dashboard
- System notifications and a floating break window that appears across Spaces
- Custom work duration, viewing distance, and break duration
- Five-minute snooze, end-early, and skip actions
- Daily summary, seven-day trends, and completion streaks
- Automatic cycle reset after screen lock, system sleep, or display sleep
- Launch at login, optional notification sounds, and local data persistence
- English and Simplified Chinese localization, including notifications and accessibility labels

## Inspiration

Long stretches of focused screen work make it easy to forget something as simple as looking away. We wanted the healthy 20-20-20 habit to feel effortless: a quiet companion that stays out of the way while you work, then creates a clear and calming moment to rest your eyes.

## What it does

EyeBreak counts down each focus interval from the macOS menu bar and reminds the user when it is time to look into the distance. A floating rest window appears across Spaces, shows a configurable countdown, and lets the user snooze or end the break early. The main dashboard explains the rule, exposes timing and system settings, and summarizes completed and skipped breaks over the last seven days. All data stays on the Mac.

## How we built it

We built the app entirely with native Apple technologies, with Codex and GPT-5.6 supporting the engineering workflow. SwiftUI powers the main window, menu bar extra, settings, statistics dashboard, and break experience. AppKit provides the floating `NSPanel` and system lifecycle integration. UserNotifications delivers reminders, ServiceManagement handles launch at login, and Swift Charts visualizes recent activity. A small reminder state machine controls focus, rest, and snoozed phases, while `UserDefaults` stores settings, active state, daily statistics, and the selected language. Apple localization resources provide English and Simplified Chinese throughout the interface.

## How Codex & GPT-5.6 were used

We used OpenAI Codex with GPT-5.6 as an agentic engineering partner throughout the project rather than only as a code-completion tool. Codex explored the Swift codebase and its dependency graph, translated product requirements into scoped edits, created the bilingual localization architecture, updated every user-facing surface, built the Xcode project, ran the XCTest suite, and verified the final application bundle.

GPT-5.6's reasoning was especially valuable during debugging. It connected runtime sampling evidence to SwiftUI's rendering behavior, traced repeated layout work to a globally published one-second clock and a recurring progress-ring animation, and helped redesign updates around small `TimelineView` subtrees. We validated the result empirically: idle CPU usage fell from roughly 24% to below 1% while the countdown remained accurate. Human direction and review defined the product decisions, copy, visual experience, and acceptance criteria; Codex and GPT-5.6 accelerated implementation, diagnosis, documentation, and verification.

## Challenges we ran into

The most demanding part was coordinating one timer state across several independent macOS surfaces: the main window, menu bar, notification callbacks, and a floating panel that must appear on every Space. We also had to handle sleep, screen lock, wake, app relaunch, early exits, and snoozes without double-counting statistics or sending duplicate reminders. Localization added another layer because interpolated durations, measurements, notification content, errors, chart labels, and accessibility text all needed to remain natural in both languages.

## Accomplishments that we're proud of

We are proud that EyeBreak feels like a focused macOS app rather than a web experience placed inside a desktop shell. It has a lightweight menu bar presence, a calm custom break window, resilient reminder-state restoration, meaningful local statistics, and no account, analytics, advertising SDK, or network dependency. The interface and system-facing messages are fully available in both English and Simplified Chinese.

## What we learned

We learned that a seemingly simple countdown becomes a distributed state problem once system inactivity and multiple windows are involved. Keeping timing logic in a testable state machine made the UI much easier to reason about. We also learned to treat localization as part of architecture rather than a final copy-editing pass, especially when values and units must be reordered for different languages.

## What's next for Eye202020

Next, we would like to add richer scheduling controls, optional pause modes for presentations and full-screen media, more accessibility customization, and longer-term insights that help users understand their screen habits without compromising privacy. We also plan to expand beyond English and Simplified Chinese and explore optional iCloud sync that remains transparent and user-controlled.

## Built with (Languages, frameworks, platforms, cloud services, databases, APIs, etc.)

- Swift 5
- SwiftUI
- AppKit
- Swift Charts
- UserNotifications
- ServiceManagement
- Foundation and `UserDefaults`
- Xcode 16
- macOS 14+
- XCTest
- Apple String Resources (`Localizable.strings`)
- OpenAI Codex for agentic code exploration, implementation, debugging, and validation
- GPT-5.6 for software-engineering reasoning and documentation support
- OpenAI image generation for the original break-window landscape asset

EyeBreak uses no cloud service, external database, third-party API, analytics SDK, or advertising SDK.

## Requirements

- macOS 14 or later
- The full Xcode application; Command Line Tools alone cannot build the `.app`

Open `Eye202020.xcodeproj`, select the `Eye202020` scheme, and press `⌘R`. The app requests notification permission on first launch, but the break window still works when notifications are disabled.

## Testing

Press `⌘U` in Xcode, or run:

```sh
xcodebuild test -project Eye202020.xcodeproj -scheme Eye202020 -destination 'platform=macOS'
```

All settings and statistics are stored locally in `UserDefaults`; no account or network service is required.

## Visual assets

- `Design/AppIcon.svg` is the editable vector source for the app icon.
- The mountain landscape in the break window was created with OpenAI's built-in image generation tool and is used as an original bitmap asset in this project.
