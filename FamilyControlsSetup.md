# Screen Time integration — activation in progress

The app now defines FAMILY_CONTROLS. Family Controls and the shared App Group
entitlements are configured for the app and all three extensions. The Screen Time
adapter conforms to the modular BlockingClient interface.

The signed device build now succeeds. All three extensions are app target
dependencies and are embedded in the app's PlugIns directory by the Embed App
Extensions copy phase. Xcode validated each embedded extension during the build.
Install this updated build before testing the custom Set intention shield.

## Flow

- Blocked tab: choose apps/websites with the system picker and enable blocking.
- Opening a selected app or website presents the custom shield.
- "Set intention" records the selected token in the shared App Group and returns
  ShieldActionResponse.openParentalControlsApp (iOS 26.5+; project targets iOS 27).
- On becoming active, This Time reads the request and presents the separate
  intention screen, followed by the timer screen. Requests expire after 5 minutes.
- Only a current shield request may start a session. Saved list entries and the
  Intentions tab cannot start sessions independently.
- A Device Activity schedule is registered before unlocking. Failure leaves the
  app blocked and shows an error.
- The monitor extension re-shields on the usage threshold callback, even while This
  Time is suspended, and also at the 24-hour window end as a fallback. Notifications
  are sent from that callback instead of a wall-clock countdown.
  Apple controls callback delivery; exact wall-clock timing must be device-tested.
- Finishing early re-shields immediately. Removing an entry removes its shield.
- The app does not automatically reopen an arbitrary third-party app after timer
  setup: Screen Time tokens do not provide a launch URL. Return to that app manually.
- Named entries and manually entered website addresses remain tracking-only.
- Usage budgets are 1–240 minutes, in one-minute increments. Each session uses a
  24-hour monitoring window with an app/website-specific DeviceActivityEvent and
  includesPastActivity: false. Unused access expires at the end of that window.
  Snoozing and independently changing intentions have been removed.

## Targets

| Target | Extension point |
| --- | --- |
| IntentionShieldAction | com.apple.ManagedSettings.shield-action-service |
| IntentionShieldConfiguration | com.apple.ManagedSettingsUI.shield-configuration-service |
| IntentionActivityMonitor | com.apple.deviceactivity.monitor-extension |

ScreenTimeShared.swift belongs to the app, shield action, and monitor targets.
Its cross-process file lock protects shared requests, selections, and sessions.
UUID session identifiers prevent a delayed callback from ending a newer session.

## Activation checklist (partially completed)

1. Use a developer team supporting Family Controls; request distribution approval
   for the app and each Screen Time extension when preparing distribution.
2. Register group.com.vigneshcorp.thistime. Add App Groups to the app and all
   three extensions, using that identifier.
3. Add the Family Controls entitlement to the app and all three extensions.
   Configure Debug and Release signing deliberately.
4. Embed the three .appex products in the app using an Embed App Extensions
   copy phase (PlugIns), and add their target dependencies. This is now configured.
5. Define FAMILY_CONTROLS in the app's Swift Active Compilation Conditions,
   retaining inherited settings. The extension targets already define
   SCREEN_TIME_EXTENSION for their shared source.
6. Run on a physical device, authorize, select apps/websites, and enable blocking.
   The runtime blocking preference defaults to off.

## Verification

The normal Personal Team app and all three unembedded extension targets build in
Xcode. The gated app source (including MainActor default isolation) and extension
source also pass type checking against the iOS Simulator SDK without changing
the app's compilation conditions or entitlements. The active scheme is restored
to this time.

Before release, verify on a supported signed device:
- Denied/cancelled authorization leaves blocking off.
- App AND website shields open the correct intention flow.
- Cancel/back/expired requests never unlock.
- Timer registration failure never unlocks.
- The selected app alone unlocks after purpose and timer are confirmed.
- Timer expiry re-shields with This Time backgrounded and force-quit.
- Completing early, deleting an entry, and turning blocking off reconcile shields.
- Revoking authorization and returning resets blocking.
- Multiple sessions and late callbacks cannot terminate a newer session.
- Shared storage failure reports errors and doesn't silently start a session.

Actual Screen Time enforcement and extension launch have not been device-tested.
Capabilities, developer signing, and extension embedding are configured and build
successfully. Actual shield presentation and redirection still require device testing.
