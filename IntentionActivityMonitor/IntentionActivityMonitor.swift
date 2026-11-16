import DeviceActivity
import Foundation
import OSLog

final class IntentionActivityMonitor: DeviceActivityMonitor {
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        complete(activity)
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        complete(activity)
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        if event.rawValue == ScreenTimeShared.usageEventName {
            complete(activity)
        } else if event.rawValue.hasPrefix(ScreenTimeShared.usageProgressPrefix),
                  let minutes = Int(event.rawValue.dropFirst(ScreenTimeShared.usageProgressPrefix.count)),
                  activity.rawValue.hasPrefix(ScreenTimeShared.activityPrefix),
                  let id = UUID(uuidString: String(activity.rawValue.dropFirst(ScreenTimeShared.activityPrefix.count))) {
            do {
                try ScreenTimeShared.update { state in
                    guard let index = state.sessions.firstIndex(where: { $0.id == id }) else { return }
                    // Duplicate, out-of-order, and previous-session callbacks cannot regress progress.
                    state.sessions[index].recordUsage(minutes: minutes, at: Date())
                }
            } catch {
                Logger(subsystem: "com.vigneshcorp.thistime", category: "IntentionMonitor")
                    .error("Could not record usage progress: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func complete(_ activity: DeviceActivityName) {
        guard activity.rawValue.hasPrefix(ScreenTimeShared.activityPrefix),
              let id = UUID(uuidString: String(activity.rawValue.dropFirst(ScreenTimeShared.activityPrefix.count))) else { return }
        do {
            try ScreenTimeShared.update { state in
                state.sessions.removeAll { $0.id == id }
            }
            ScreenTimeShared.stopSession(id)
        } catch {
            Logger(subsystem: "com.vigneshcorp.thistime", category: "IntentionMonitor")
                .error("Could not restore shield: \(error.localizedDescription, privacy: .public)")
        }
    }
}
