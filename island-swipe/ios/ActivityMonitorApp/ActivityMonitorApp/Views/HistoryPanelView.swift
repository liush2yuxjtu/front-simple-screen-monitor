import SwiftUI

struct HistoryPanelView: View {
    let entries: [MonitorHistoryEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT DECISIONS")
                .terminalFont(size: 10, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(TerminalNoirTheme.cyan)
                .tracking(1.8)

            if entries.isEmpty {
                Text("Awaiting completed swipe decisions.")
                    .terminalFont(size: 11, weight: .medium, relativeTo: .footnote)
                    .foregroundStyle(TerminalNoirTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    .accessibilityLabel("No completed decisions yet")
            } else {
                VStack(spacing: 7) {
                    ForEach(entries) { entry in
                        HistoryRow(entry: entry)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TerminalNoirTheme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TerminalNoirTheme.border, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Recent decisions")
    }
}

private struct HistoryRow: View {
    let entry: MonitorHistoryEntry

    private var tint: Color {
        switch entry.decision {
        case .allow:
            return TerminalNoirTheme.lime
        case .block:
            return TerminalNoirTheme.red
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 7, height: 7)
                .shadow(color: tint.opacity(0.4), radius: 5)

            Text(entry.activity.intent)
                .terminalFont(size: 11, weight: .medium, relativeTo: .footnote)
                .foregroundStyle(TerminalNoirTheme.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(entry.decision.rawValue)
                .terminalFont(size: 9, weight: .bold, relativeTo: .caption2)
                .foregroundStyle(tint)
                .tracking(1.0)

            Text(entry.date.formatted(date: .omitted, time: .shortened))
                .terminalFont(size: 9, weight: .medium, relativeTo: .caption2)
                .foregroundStyle(TerminalNoirTheme.muted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(TerminalNoirTheme.surface.opacity(0.55), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(TerminalNoirTheme.border.opacity(0.9), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.activity.intent), \(entry.decision.rawValue)")
        .accessibilityValue(entry.date.formatted(date: .omitted, time: .shortened))
    }
}
