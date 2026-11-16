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
