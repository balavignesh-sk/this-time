import SwiftUI

struct HistoryView: View {
    let entries: [SessionHistoryEntry]
    @State private var threads: [IntentionThread] = []

    var body: some View {
        List {
            if entries.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Eyebrow(title: "REFLECT")
                    Text("Nothing here yet.").font(.title2)
                    Text("Your answers will appear here, grouped by app or website.")
                        .foregroundStyle(Paper.muted)
                }
                .padding(.vertical, 24)
                .listRowBackground(Paper.background)
            }
            ForEach(threads) { thread in
                NavigationLink {
                    IntentionThreadView(thread: thread)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        ServiceLabel(service: thread.service)
                        Text(thread.entries.first?.intention ?? "").lineLimit(2)
                            .font(.subheadline).foregroundStyle(Paper.muted)
                        Text("\(thread.entries.count) answers")
                            .font(.caption).foregroundStyle(Paper.muted)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Paper.background)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Paper.background)
        .navigationTitle("Reflect")
        .task(id: entries.map(\.id)) { threads = IntentionThread.group(entries) }
    }
}

private struct IntentionThread: Identifiable {
    let id: String
    let service: Service
    var entries: [SessionHistoryEntry]

    static func group(_ entries: [SessionHistoryEntry]) -> [Self] {
        var result: [Self] = []
        var indices: [String: Int] = [:]
        for entry in entries {
            // Token identity keeps a thread together if an item is removed and re-added.
            let key = entry.service.applicationTokenData.map { "app:" + $0.base64EncodedString() }
                ?? entry.service.webDomainTokenData.map { "web:" + $0.base64EncodedString() }
                ?? entry.service.categoryTokenData.map { "category:" + $0.base64EncodedString() }
                ?? entry.service.id
            if let index = indices[key] {
                result[index].entries.append(entry)
            } else {
                indices[key] = result.count
                result.append(Self(id: key, service: entry.service, entries: [entry]))
            }
        }
        return result
    }
}

private struct IntentionThreadView: View {
    let thread: IntentionThread

    var body: some View {
        List {
            Section { ServiceLabel(service: thread.service) }
                .listRowBackground(Paper.background)
            ForEach(thread.entries) { entry in
                IntentionEntryRow(entry: entry)
                    .listRowBackground(Paper.background)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Paper.background)
        .navigationTitle("Your answers")
    }
}

private struct IntentionEntryRow: View {
    let entry: SessionHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(entry.startedAt, format: .dateTime.month().day().hour().minute())
                .font(.caption).foregroundStyle(Paper.muted)
            if let prompt = entry.prompt { Text(prompt).foregroundStyle(Paper.muted) }
            Text(entry.intention).font(.body)
            Label(entry.unlocked ? "Unlocked · \(entry.minutes) min allowed" : "Left locked",
                  systemImage: entry.unlocked ? "lock.open" : "leaf")
                .font(.caption).foregroundStyle(entry.unlocked ? Paper.muted : Paper.orange)
        }
        .padding(.vertical, 16)
    }
}
