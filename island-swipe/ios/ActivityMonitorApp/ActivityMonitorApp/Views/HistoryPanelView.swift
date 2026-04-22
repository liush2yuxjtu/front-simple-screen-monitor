import SwiftUI

struct HistoryPanelView: View {
    let entries: [MonitorHistoryEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT DECISIONS")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.cyan)
                .tracking(1.8)

            if entries.isEmpty {
                Text("Awaiting completed swipe decisions.")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(TerminalNoirTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
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
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(entry.decision.rawValue)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(tint)
                .tracking(1.0)

            Text(entry.date.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.muted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(TerminalNoirTheme.surface.opacity(0.55), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(TerminalNoirTheme.border.opacity(0.9), lineWidth: 1)
        }
    }
}

