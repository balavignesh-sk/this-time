# this tim

## Product flow

- Onboarding explains the intention loop, requests Screen Time, and offers optional notifications.
- Rules manages selected apps, categories, websites, a custom unlock duration,
  and editable alternative activities.
- A shield's secondary button stores a request in the App Group and sends a local notification.
  Users can also initiate the same request from Rules without notification permission.
- A prompt asks for at least ten trimmed characters, optionally referring to a recent answer or
  a personal alternative. Confirmation lets the user unlock or step away.
- Reflect groups answers by opaque token and records both decisions with prompt and timestamp.
- Settings includes instructions, permissions, protection control, and history deletion.

## Boundaries

ContentView owns presentation and the observable IntentionStore. Views call the store;
the store depends on BlockingClient, AppPreferences, and SessionNotifications.
MyApp installs a retained notification delegate; BlockingLifecycle reconciles on activation
and notification responses.

AppBlocking registers DeviceActivity enforcement before granting access. Registration failure
keeps the item shielded and creates no successful history entry. Every decision revalidates
its request identity. App and category budgets count active use, exclude past activity, and
have a 24-hour safety expiry. Manual relock ends a grant early.

Websites unlock as a set, matching the reference's handling of cross-process website token
identity. Their duration is elapsed time. Short grants use a 15-minute monitor with an early
warning callback; interval-end remains a fallback. iOS delivery is not an exact timer.
Selected individual apps with active grants are exceptions to category shields. A separately
selected app remains shielded when only its category is unlocked.

ScreenTimeShared uses flock and atomic JSON writes to coordinate separate processes.
Do not replace this with an in-process actor. IntentionActivityMonitor removes grants on
usage threshold, interval warning, or interval end and reapplies the current selection.

## Persistence and migration

Existing service/history keys are retained. Category tokens, stored prompts, and decision
outcomes are additive optional fields. Historical records without an outcome mean unlocked.
Intention preferences use thisTime.intention.v1. Existing selections and answers survive.
Shared timing version 2 ends old grants and stops old schedules/idle monitors; legacy
cooldowns and schedules no longer govern access. The old timing-policy source is archival.

There are no external dependencies, analytics, accounts, or backend. Implementation uses
Apple frameworks and the existing application identifiers and App Group.

## Validation

Xcode builds and injected behavior checks cover compilation, legacy decoding, reason length,
failed registration, success/duplicate decisions, stale requests, step-away history, manual
relock, alternatives, duration validation, and history deletion.

Physical-device validation is still required for Family Controls authorization, category and
website token behavior, notification-to-app handoff, and background threshold/warning delivery.
The project currently has Family Controls development entitlements; distribution entitlement
approval remains a separate signing requirement.

## Live Activities

IntentionLiveActivityExtension renders the intention on the Lock Screen and in the
Dynamic Island. IntentionActivityAttributes is shared with the app and the Screen
Time targets. The app starts an activity only after a grant has been committed;
disabled or unavailable Live Activities do not prevent an otherwise valid unlock.

App/category monitoring registers cumulative one-minute progress thresholds alongside
the final enforcement threshold. The monitor records the highest confirmed usage
minute under the existing shared file lock. Duplicate, late, and out-of-order callbacks
cannot reset progress or affect a replacement session. SessionActivityPublisher reads
committed storage to update or end existing activities after grants change, including
manual relock, removal, protection being disabled, and expiry.

The displayed usage value is an upper bound on remaining minutes, not a wall-clock
countdown. The collapsed and minimal Dynamic Island presentations emphasize a timer
ring showing the remaining fraction; the expanded view pairs it with the intention
and a plain-text “this app” reference. FamilyControls token labels cannot render in
this Live Activity, so the widget avoids those remote views. Each report carries its receipt time. After
90 seconds without a report, the existing usage ring and last confirmed remaining value fade lightly to 65%
opacity, retaining the timer icon and the last known progress. Accessibility identifies it as last confirmed.
Returning to the app does not refresh that timestamp or reset usage. Website rings
count down to the stored elapsed-time deadline and stay empty at zero until the
session is removed. Website grants replace earlier website grants because all
selected websites share access. Token data is optional for older activities, and
oversized payloads fall back to “your selection” to stay within ActivityKit's limit.

Screen Time callbacks and extension execution are system-scheduled, so this does not
promise exact second-by-second usage or immediate background ActivityKit delivery.
ActivityKit also imposes its own lifetime limit (up to eight active hours), independently
of the 24-hour usage monitoring window. The monitor still enforces limits if an
activity is dismissed, unavailable, or has ended.

Validation: Xcode build and executable checks cover budget calculations, stale deadlines,
clamping, duplicate/out-of-order progress, invalid thresholds, and legacy session decoding.
Physical-device checks still needed: background progress delivery, force-quit behavior,
early relock, website expiry, multiple grants, disabled Live Activities, and long budgets
with many threshold events. See Apple's [Live Activities documentation](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
for lifecycle and payload limits.
