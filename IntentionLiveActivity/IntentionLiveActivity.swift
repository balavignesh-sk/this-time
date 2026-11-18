import ActivityKit
import SwiftUI
import WidgetKit

private enum ActivityColors {
    static let background = Color(uiColor: .systemBackground)
    static let text = Color(uiColor: .label)
    static let accent = Color.orange
    static let track = Color(uiColor: .tertiaryLabel)
}

struct IntentionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IntentionActivityAttributes.self) { context in
            IntentionActivityCard(context: context)
                .padding()
                .foregroundStyle(ActivityColors.text)
                .background(ActivityColors.background)
                .activityBackgroundTint(ActivityColors.background)
                .activitySystemActionForegroundColor(ActivityColors.text)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    IntentionActivityCard(context: context)
                }
            } compactLeading: {
                RemainingTimeRing(context: context)
                    .frame(width: 24, height: 24)
            } compactTrailing: {
                RemainingTimeText(context: context)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .frame(maxWidth: 56)
            } minimal: {
                RemainingTimeRing(context: context)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

private struct IntentionActivityCard: View {
    let context: ActivityViewContext<IntentionActivityAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(spacing: 7) {
                RemainingTimeRing(context: context)
                    .frame(width: 40, height: 40)
                RemainingTimeText(context: context)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
            }
            .fixedSize()
            VStack(alignment: .leading, spacing: 5) {
                IntentionOpeningText(attributes: context.attributes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("“\(context.attributes.intention)”")
                    .font(.body.weight(.medium))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .privacySensitive()
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
    }
}

// FamilyControls token labels use a remote view that Live Activities cannot render.
// Keep the private selection in the app; this presentation uses ordinary SwiftUI text.
private struct IntentionOpeningText: View {
    let attributes: IntentionActivityAttributes

    var body: some View {
        if attributes.timing == .elapsed {
            Text("You wanted to browse because")
        } else if attributes.categoryTokenData != nil {
            Text("You wanted to open these apps because")
        } else {
            Text("You wanted to open this app because")
        }
    }
}

/// A full ring means the whole budget remains. Usage rings move only on confirmed reports.
private struct RemainingTimeRing: View {
    let context: ActivityViewContext<IntentionActivityAttributes>
    private let accent = ActivityColors.accent

    var body: some View {
        ZStack {
            if context.attributes.timing == .elapsed && !context.state.ended {
                ProgressView(
                    timerInterval: context.attributes.startedAt...context.attributes.deadline,
                    countsDown: true
                ) {
                    Text("Time remaining")
                } currentValueLabel: {
                    EmptyView()
                }
                .progressViewStyle(.circular)
                .tint(accent)
            } else {
                Circle()
                    .stroke(ActivityColors.track, lineWidth: 3)
                Circle()
                    .trim(from: 0, to: context.state.ended ? 0 :
                        CGFloat(context.attributes.remainingMinutes(for: context.state)) /
                        CGFloat(max(1, context.attributes.minutes)))
                    .stroke(accent, style: StrokeStyle(
                        lineWidth: 3, lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))
            }
            Image(systemName: context.state.ended ? "checkmark" : "timer")
                .font(.caption2.weight(.bold))
                .foregroundStyle(accent)
                .padding(6)
        }
        .opacity(context.isStale && !context.state.ended ? 0.65 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time remaining")
        .accessibilityValue(context.state.ended ? Text("Ended") :
            context.isStale ? Text("Awaiting update") :
            context.attributes.timing == .usage ?
                Text("At most \(context.attributes.remainingMinutes(for: context.state)) of \(context.attributes.minutes) minutes remaining") :
                Text("Website access counts down to its expiry"))
    }
}

private struct RemainingTimeText: View {
    let context: ActivityViewContext<IntentionActivityAttributes>

    var body: some View {
        if context.state.ended {
            Text("Ended")
        } else if context.attributes.timing == .elapsed {
            if context.isStale {
                Text("0:00")
                    .opacity(0.65)
            } else {
                Text(timerInterval: context.attributes.startedAt...context.attributes.deadline, countsDown: true)
            }
        } else {
            Text("≤\(context.attributes.remainingMinutes(for: context.state))m")
                .opacity(context.isStale ? 0.65 : 1)
                .accessibilityLabel("Last confirmed: at most \(context.attributes.remainingMinutes(for: context.state)) minutes remaining")
        }
    }
}

#Preview("Intention card", as: .content, using: IntentionActivityAttributes(
    sessionID: UUID(),
    intention: "I want to test the live activity and then get back to my work.",
    minutes: 15,
    timing: .usage,
    startedAt: .now,
    deadline: .now.addingTimeInterval(86400)
)) {
    IntentionLiveActivity()
} contentStates: {
    IntentionActivityAttributes.ContentState(confirmedUsedMinutes: 4, reportedAt: .now)
}
