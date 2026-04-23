import SwiftUI

struct HintPanelView: View {
    private let thresholdLabel = "\(Int(MonitorSessionState.decisionThreshold))pt"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HOW IT WORKS")
                .terminalFont(size: 10, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(TerminalNoirTheme.cyan)
                .tracking(1.8)

            VStack(alignment: .leading, spacing: 9) {
                HintStep(index: 1, text: "Activity detected → pill expands")
                HintStep(index: 2, text: "Swipe LEFT beyond \(thresholdLabel) → BLOCK")
                HintStep(index: 3, text: "Swipe RIGHT beyond \(thresholdLabel) → ALLOW")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TerminalNoirTheme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TerminalNoirTheme.border, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("How it works")
        .accessibilityHint("Activities expand into the pill. Swipe left beyond \(thresholdLabel) to block, or right beyond \(thresholdLabel) to allow.")
    }
}

private struct HintStep: View {
    let index: Int
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(TerminalNoirTheme.cyan.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(TerminalNoirTheme.border, lineWidth: 1)
                    }

                Text("\(index)")
                    .terminalFont(size: 9, weight: .bold, relativeTo: .caption2)
                    .foregroundStyle(TerminalNoirTheme.cyan)
            }
            .frame(width: 18, height: 18)

            Text(text)
                .terminalFont(size: 11, weight: .medium, relativeTo: .footnote)
                .foregroundStyle(TerminalNoirTheme.muted)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(index). \(text)")
    }
}
