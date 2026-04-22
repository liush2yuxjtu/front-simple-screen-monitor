import SwiftUI

struct HintPanelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HOW IT WORKS")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.cyan)
                .tracking(1.8)

            VStack(alignment: .leading, spacing: 9) {
                HintStep(index: 1, text: "Activity detected → pill expands")
                HintStep(index: 2, text: "Swipe LEFT beyond 90pt → BLOCK")
                HintStep(index: 3, text: "Swipe RIGHT beyond 90pt → ALLOW")
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
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(TerminalNoirTheme.cyan)
            }
            .frame(width: 18, height: 18)

            Text(text)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.muted)
        }
    }
}

