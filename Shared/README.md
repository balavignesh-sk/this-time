# Shared app and extension code

These sources compile into multiple targets so the app and its extensions agree on session state and Live Activity payloads. Keep them outside any single target's source folder.

 |
Preserve explicit target membership when moving these files. Shared storage must retain its cross-process file lock: an actor alone cannot coordinate separate extension processes. Optional persisted fields allow older sessions and activities to decode after updates.

See [Architecture](../Architecture.md) for the session lifecycle.
