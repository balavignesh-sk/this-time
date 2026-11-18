import SwiftUI

struct HistoryView: View {
    let entries: [SessionHistoryEntry]

    var body: some View {
        let sortedEntries = entries.sorted { $0.startedAt > $1.startedAt }

        List {
            Section {
                if entries.isEmpty {
                    Text("Your intentions will appear here.")
                        .foregroundStyle(Paper.muted)
                        .listRowBackground(Paper.background)
                }
                ForEach(sortedEntries) { entry in
                    IntentionEntryRow(entry: entry)
                        .listRowInsets(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                        .listRowSeparator(entry.id == sortedEntries.first?.id ? .hidden : .visible, edges: .top)
                        .listRowSeparator(entry.id == sortedEntries.last?.id ? .hidden : .visible, edges: .bottom)
                        .listRowSeparatorTint(Paper.ink.opacity(0.07))
                        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                        .alignmentGuide(.listRowSeparatorTrailing) { dimensions in dimensions.width }
                        .listRowBackground(Paper.background)
                }
            }
            .listSectionSeparator(.hidden)
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
        VStack(alignment: .leading, spacing: 8) {
            ServiceLabel(service: entry.service)
                .labelStyle(ServiceRowLabelStyle())
                .font(.subheadline.weight(.semibold))
            Text(entry.intention)
                .font(.subheadline)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
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
        .fontDesign(.default)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


