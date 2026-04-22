import SwiftUI

struct MonitorWindowView: View {
    @ObservedObject var store: MonitorStore

    var body: some View {
        ZStack {
            MonitorBackdropView()

            VStack(spacing: 28) {
                HeaderPanelView()
                PhoneMockupView(
                    session: store.session,
                    threshold: store.decisionThreshold,
                    onTapNotification: store.expandNow,
                    onDragChanged: store.updateDrag,
                    onDragEnded: store.endDrag
                )
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            store.bootstrap()
        }
    }
}

private struct HeaderPanelView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("灵动岛 · Activity Monitor")
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.text)
                .tracking(1.6)

            Text("Swipe to decide · Left = BLOCK · Right = ALLOW")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.muted)
                .tracking(1.1)

            HStack(spacing: 10) {
                HeaderChip(text: "AUTO-EXPAND 1.2S", tint: TerminalNoirTheme.cyan)
                HeaderChip(text: "THRESHOLD 90PT", tint: TerminalNoirTheme.lime)
                HeaderChip(text: "MACOS SWIPE INPUT", tint: TerminalNoirTheme.red)
            }
        }
        .frame(maxWidth: 860)
    }
}

private struct HeaderChip: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.09), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(tint.opacity(0.22), lineWidth: 1)
            }
    }
}

private struct MonitorBackdropView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    TerminalNoirTheme.background,
                    Color(hex: 0x06101A),
                    TerminalNoirTheme.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(TerminalNoirTheme.cyan.opacity(0.18))
                .frame(width: 380, height: 380)
                .blur(radius: 150)
                .offset(x: -260, y: -170)

            Circle()
                .fill(TerminalNoirTheme.lime.opacity(0.08))
                .frame(width: 340, height: 340)
                .blur(radius: 160)
                .offset(x: 290, y: 220)

            Canvas(rendersAsynchronously: true) { context, size in
                var vertical = Path()
                stride(from: 0.0, through: size.width, by: 56).forEach { x in
                    vertical.move(to: CGPoint(x: x, y: 0))
                    vertical.addLine(to: CGPoint(x: x, y: size.height))
                }

                var horizontal = Path()
                stride(from: 0.0, through: size.height, by: 56).forEach { y in
                    horizontal.move(to: CGPoint(x: 0, y: y))
                    horizontal.addLine(to: CGPoint(x: size.width, y: y))
                }

                context.stroke(vertical, with: .color(TerminalNoirTheme.cyan.opacity(0.04)), lineWidth: 0.5)
                context.stroke(horizontal, with: .color(TerminalNoirTheme.cyan.opacity(0.03)), lineWidth: 0.5)
            }
        }
        .ignoresSafeArea()
    }
}
