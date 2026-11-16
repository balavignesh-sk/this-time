import SwiftUI

struct IntentionDurationPicker: View {
    @Binding var minutes: Int

    private var hours: Binding<Int> {
        Binding(
            get: { minutes / 60 },
            set: { hours in
                minutes = min(max(hours * 60 + minutes % 60,
                                  SessionPolicy.minimumMinutes),
                              SessionPolicy.maximumMinutes)
            }
        )
    }

    private var remainingMinutes: Binding<Int> {
        Binding(
            get: { minutes % 60 },
            set: { minutes = (minutes / 60) * 60 + $0 }
        )
    }

    private var minuteRange: ClosedRange<Int> {
        if minutes / 60 == SessionPolicy.maximumMinutes / 60 { return 0...0 }
        return (minutes < 60 ? SessionPolicy.minimumMinutes : 0)...59
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow(title: "HOW LONG?")
            HStack(spacing: 12) {
                VStack(spacing: 0) {
                    Text("Hours").font(.caption).foregroundStyle(Paper.muted)
                    Picker("Hours", selection: hours) {
                        ForEach(0...(SessionPolicy.maximumMinutes / 60), id: \.self) { hour in
                            Text(hour, format: .number).tag(hour)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
                VStack(spacing: 0) {
                    Text("Minutes").font(.caption).foregroundStyle(Paper.muted)
                    Picker("Minutes", selection: remainingMinutes) {
                        ForEach(minuteRange, id: \.self) { minute in
                            Text(minute, format: .number).tag(minute)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
    }
}
