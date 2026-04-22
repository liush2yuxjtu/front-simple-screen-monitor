import SwiftUI

struct PhoneMockupView: View {
    let session: MonitorSessionState
    let threshold: CGFloat
    let onTapNotification: () -> Void
    let onDragChanged: (CGFloat) -> Void
    let onDragEnded: (CGFloat) -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 54, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            TerminalNoirTheme.phoneMetal,
                            TerminalNoirTheme.phoneFrame
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .stroke(TerminalNoirTheme.border.opacity(0.65), lineWidth: 1)
                .padding(3)

            RoundedRectangle(cornerRadius: 46, style: .continuous)
                .fill(Color.black)
                .padding(8)

            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            TerminalNoirTheme.surfaceElevated,
                            TerminalNoirTheme.surface
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(14)
                .overlay {
                    PhoneScreenView(
                        session: session,
                        threshold: threshold,
                        onTapNotification: onTapNotification,
                        onDragChanged: onDragChanged,
                        onDragEnded: onDragEnded
                    )
                    .padding(28)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                }

            SideButtonStrip()
        }
        .frame(width: 372, height: 746)
        .shadow(color: TerminalNoirTheme.cyan.opacity(0.08), radius: 28, y: 16)
        .shadow(color: .black.opacity(0.5), radius: 44, y: 24)
    }
}

private struct PhoneScreenView: View {
    let session: MonitorSessionState
    let threshold: CGFloat
    let onTapNotification: () -> Void
    let onDragChanged: (CGFloat) -> Void
    let onDragEnded: (CGFloat) -> Void

    private var phaseTint: Color {
        switch session.phase {
        case .accepted:
            return TerminalNoirTheme.lime
        case .denied:
            return TerminalNoirTheme.red
        default:
            return TerminalNoirTheme.cyan
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(TerminalNoirTheme.surface)

            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(TerminalNoirTheme.border, lineWidth: 1)

            Circle()
                .fill(TerminalNoirTheme.cyan.opacity(0.1))
                .frame(width: 220, height: 220)
                .blur(radius: 90)
                .offset(x: -70, y: -150)

            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(phaseTint.opacity(session.phase == .accepted || session.phase == .denied ? 0.08 : 0))

            Canvas(rendersAsynchronously: true) { context, size in
                var lines = Path()
                stride(from: 0.0, through: size.height, by: 18).forEach { y in
                    lines.move(to: CGPoint(x: 0, y: y))
                    lines.addLine(to: CGPoint(x: size.width, y: y))
                }

                context.stroke(lines, with: .color(TerminalNoirTheme.cyan.opacity(0.018)), lineWidth: 0.4)
            }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    StatusBadge(title: "LIVE", tint: TerminalNoirTheme.cyan)
                    StatusBadge(title: session.phase.label, tint: phaseTint)
                    Spacer()
                    Text("MONITOR")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(TerminalNoirTheme.muted)
                        .tracking(1.6)
                }

                DynamicIslandMonitorView(
                    session: session,
                    threshold: threshold,
                    availableWidth: 280,
                    onTapNotification: onTapNotification,
                    onDragChanged: onDragChanged,
                    onDragEnded: onDragEnded
                )
                .frame(maxWidth: .infinity, alignment: .center)

                StatsPanelView(session: session)

                SessionDeckView(session: session)

                Spacer(minLength: 0)

                RecentDecisionBar(entries: session.history)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

private struct StatusBadge: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundStyle(tint)
            .tracking(1.4)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.08), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(tint.opacity(0.22), lineWidth: 1)
            }
    }
}

private struct SessionDeckView: View {
    let session: MonitorSessionState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CURRENT CONTEXT")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.cyan)
                .tracking(1.8)

            if let activity = session.currentActivity {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Text(activity.intent)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundStyle(TerminalNoirTheme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)

                        RiskBadge(risk: activity.risk)
                    }

                    Text(activity.reasonShort.uppercased())
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(TerminalNoirTheme.muted)
                        .tracking(1.1)

                    Text(activity.reason)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(TerminalNoirTheme.text.opacity(0.82))
                        .lineSpacing(3)
                        .lineLimit(3)
                }
            } else {
                Text("STANDBY · waiting for next simulated activity item.")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(TerminalNoirTheme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(TerminalNoirTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TerminalNoirTheme.border, lineWidth: 1)
        }
    }
}

private struct RecentDecisionBar: View {
    let entries: [MonitorHistoryEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RECENT DECISIONS")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.cyan)
                .tracking(1.8)

            if entries.isEmpty {
                Text("No decisions yet. Swipe to ALLOW or BLOCK.")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(TerminalNoirTheme.muted)
            } else {
                HStack(spacing: 8) {
                    ForEach(Array(entries.prefix(3))) { entry in
                        DecisionChip(entry: entry)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DecisionChip: View {
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
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.decision.rawValue)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(tint)

            Text(entry.activity.appName.uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.text)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(TerminalNoirTheme.glass, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(TerminalNoirTheme.border.opacity(0.95), lineWidth: 1)
        }
    }
}

private struct SideButtonStrip: View {
    var body: some View {
        ZStack {
            VStack(spacing: 36) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(TerminalNoirTheme.phoneMetal)
                    .frame(width: 4, height: 56)
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(TerminalNoirTheme.phoneMetal)
                    .frame(width: 4, height: 70)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .offset(x: -2, y: 92)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(TerminalNoirTheme.phoneMetal)
                .frame(width: 4, height: 96)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .offset(x: 2, y: 80)
        }
    }
}
