# Legacy timing policy

SessionExpiryPolicy.swift is retained as an archive of the previous cooldown, snooze,
inactivity-reset, and schedule rules. The intention overhaul no longer calls this policy.

Current enforcement lives in AppBlocking, ScreenTimeShared, and IntentionActivityMonitor.
Apps and categories count active use; websites use elapsed time and unlock as a set.
Short website grants use a 15-minute DeviceActivity interval and an earlier warning.
System callbacks may be delayed. See Architecture.md for the current flow and migration.
