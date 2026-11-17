import SwiftUI

struct HistoryView: View {
    let entries: [SessionHistoryEntry]

    var body: some View {
        List {
            if entries.isEmpty {
                Text("Your intentions will appear here.")
                    .foregroundStyle(Paper.muted)
                    .listRowBackground(Paper.background)
            }
            ForEach(entries.sorted { $0.startedAt > $1.startedAt }) { entry in
                IntentionEntryRow(entry: entry)
                    .listRowBackground(Paper.background)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Paper.background)
        .navigationTitle("History")
    }
}

private struct IntentionEntryRow: View {
    let entry: SessionHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ServiceLabel(service: entry.service)
                .font(.subheadline.weight(.semibold))
            Text(entry.intention)
                .font(.body)
            HStack {
                Text(entry.startedAt, format: .dateTime.month().day().hour().minute())
                Spacer()
                if entry.didUnlock {
                    Text("\(entry.minutes) min")
                } else {
                    Text("Left locked")
                }
            }
            .font(.caption)
            .foregroundStyle(Paper.muted)
        }
        .padding(.vertical, 12)
    }
}
