import SwiftUI

struct StatsPanelView: View {
    let session: MonitorSessionState

    var body: some View {
        HStack(spacing: 10) {
            StatCell(
                value: session.allowedCount,
                label: "ALLOWED",
                tint: TerminalNoirTheme.lime
            )

            StatCell(
                value: session.blockedCount,
                label: "BLOCKED",
                tint: TerminalNoirTheme.red
            )

            StatCell(
                value: session.totalCount,
                label: "TOTAL",
                tint: TerminalNoirTheme.cyan
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Decision counters")
    }
}

private struct StatCell: View {
    let value: Int
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .terminalFont(size: 28, weight: .bold, relativeTo: .title2)
                .foregroundStyle(tint)
                .contentTransition(.numericText(value: Double(value)))
                .animation(AnimationTokens.statsCount, value: value)

            Text(label)
                .terminalFont(size: 10, weight: .medium, relativeTo: .caption2)
                .foregroundStyle(TerminalNoirTheme.muted)
                .tracking(1.4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(TerminalNoirTheme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(TerminalNoirTheme.border, lineWidth: 1)
        }
        .overlay(alignment: .top) {
            Capsule()
                .fill(tint.opacity(0.3))
                .frame(width: 74, height: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label.capitalized)
        .accessibilityValue("\(value)")
    }
}
