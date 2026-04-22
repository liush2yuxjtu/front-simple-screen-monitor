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
    }
}

private struct StatCell: View {
    let value: Int
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.system(size: 27, weight: .bold, design: .monospaced))
                .foregroundStyle(tint)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.muted)
                .tracking(1.4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(TerminalNoirTheme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TerminalNoirTheme.border, lineWidth: 1)
        }
        .overlay(alignment: .top) {
            Capsule()
                .fill(tint.opacity(0.3))
                .frame(width: 70, height: 1)
        }
    }
}
