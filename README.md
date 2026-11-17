# this time

For those who press “ignore” on their Screen Time.

this time is a SwiftUI iOS app that adds a moment of intention before opening distracting apps and websites. Write why you want to use something, then choose to unlock it for a limited duration or step away.

## How it works

1. Allow Screen Time access during onboarding, and optionally enable notifications.
2. In **Rules**, choose apps, categories, and websites to protect using Apple's system picker.
3. Request access from a shield or from Rules. A shield request can send a notification that brings you back to the app.
4. Write an intention of at least 10 characters and choose an unlock duration from 1–240 minutes.
5. Unlock the item or step away. Both decisions are saved in **Reflect**, alongside the prompt and timestamp.

You can also manage alternative activities, lock an item again early, and clear your history from Settings.

## Timing and protection

- **Apps and categories:** the duration is an active-use budget, with a 24-hour safety expiry. It is not a continuous wall-clock countdown.
- **Websites:** access uses elapsed time, and selected websites unlock as a set.
- Device Activity monitoring is registered before access is granted. If registration fails, the item stays protected.
- The monitor extension restores shields when the relevant usage threshold or timing callback arrives. System callback delivery can be delayed.

## Development setup

1. Open `this time.xcodeproj` in Xcode and select the **this time** scheme.
2. Use an Xcode installation with the SDK required by the project's deployment target; the setup notes currently specify iOS 27.
3. Configure your development team for the app and all three extension targets.
4. Configure **Family Controls** and **App Groups** for all four targets. The shared App Group identifier is `group.com.vigneshcorp.thistime`; if you change it, update the shared code and entitlements consistently.
5. Keep `FAMILY_CONTROLS` enabled in the app's Swift Active Compilation Conditions. The extension targets use `SCREEN_TIME_EXTENSION` for shared source.
6. Verify that the app embeds all three extensions, then build and run on a signed physical device to test Screen Time behavior.

There are no external package dependencies. Family Controls distribution approval is a separate requirement when preparing a release.

See [Family Controls setup](FamilyControlsSetup.md) for signing, entitlements, and device checks. That document includes historical flow details; the current behavior is described above and in [Architecture](Architecture.md).

## Project structure

| Path | Purpose |
| --- | --- |
| `this time/Views/` | Onboarding, Rules, intention flow, Reflect, and Settings UI |
| `this time/ViewModels/IntentionStore.swift` | Observable application state and user decisions |
| `this time/Models/` | Services, preferences, prompts, session policy, and history |
| `this time/Services/` | Blocking, persistence, notifications, and dependency configuration |
| `this time/Helpers/BlockingLifecycle.swift` | Reconciliation when the app becomes active or handles notifications |
| [`Shared/`](Shared/README.md) | Cross-target Screen Time state and Live Activity attributes; includes target membership notes |
| `IntentionShieldConfiguration/` | Screen Time shield appearance |
| `IntentionShieldAction/` | Shield button actions and unlock requests |
| `IntentionActivityMonitor/` | Background usage and timing callbacks that restore protection |
| `SessionExpiry/` | Archived timing policy; not the current enforcement implementation |

Views call `IntentionStore`, which depends on interfaces for blocking, persistence, and notifications. Shared Screen Time state uses file locking and atomic JSON writes to coordinate the app and extensions. See [Architecture](Architecture.md) for implementation boundaries and migration details.

## Privacy

Selections and intention history stay on the device. The app has no accounts, analytics, or backend. Screen Time selections use Apple's opaque tokens, and notifications are optional.

## Validation

Build with Xcode's **Product → Build**. Screen Time authorization, shield presentation, notification handoff, category and website behavior, and background enforcement require testing on a physical device. Existing project notes report successful builds, but physical-device validation remains outstanding.
