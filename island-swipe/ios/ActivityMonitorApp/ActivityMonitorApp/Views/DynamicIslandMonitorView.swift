import SwiftUI

struct DynamicIslandMonitorView: View {
    let session: MonitorSessionState
    let threshold: CGFloat
    let availableWidth: CGFloat
    let onTapNotification: () -> Void
    let onDragChanged: (CGFloat) -> Void
    let onDragEnded: (CGFloat) -> Void

    var body: some View {
        let layout = islandLayout
        let accent = accentColor
        let offset = CGFloat(session.dragOffset)

        ZStack {
            RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
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

            RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                .fill(accent.opacity(session.dragProgress * 0.14))

            RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                .stroke(
                    accent.opacity(max(0.12, session.dragProgress * 0.45)),
                    lineWidth: 1
                )

            RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                .stroke(TerminalNoirTheme.border.opacity(0.9), lineWidth: 1)

            content
                .padding(layout.contentPadding)
        }
        .frame(width: layout.width, height: layout.height)
        .offset(x: offset * 0.08)
        .shadow(color: accent.opacity(0.18 + session.dragProgress * 0.15), radius: 22, y: 12)
        .shadow(color: .black.opacity(0.4), radius: 28, y: 14)
        .overlay(alignment: .top) {
            Capsule()
                .fill(accent.opacity(0.28))
                .frame(width: layout.width * 0.54, height: 1)
                .blur(radius: 0.3)
                .padding(.top, 0.5)
        }
        .contentShape(RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous))
        .onTapGesture {
            guard session.phase == .notification else {
                return
            }
            onTapNotification()
        }
        .gesture(dragGesture, including: session.phase.allowsDrag ? .all : .none)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: session.phase)
        .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.84), value: session.dragOffset)
    }

    private var islandLayout: IslandLayout {
        switch session.phase {
        case .idle:
            return IslandLayout(width: min(126, availableWidth), height: 37, cornerRadius: 22, contentPadding: 10)
        case .notification:
            return IslandLayout(width: min(340, availableWidth), height: 38, cornerRadius: 22, contentPadding: 14)
        case .expanded, .dragging:
            return IslandLayout(
                width: min(370, availableWidth),
                height: availableWidth < 350 ? 398 : 426,
                cornerRadius: 34,
                contentPadding: 18
            )
        case .accepted, .denied:
            return IslandLayout(width: min(208, availableWidth), height: 38, cornerRadius: 22, contentPadding: 12)
        }
    }

    private var accentColor: Color {
        if session.phase == .accepted {
            return TerminalNoirTheme.lime
        }

        if session.phase == .denied {
            return TerminalNoirTheme.red
        }

        if session.dragOffset > 0 {
            return TerminalNoirTheme.lime
        }

        if session.dragOffset < 0 {
            return TerminalNoirTheme.red
        }

        return TerminalNoirTheme.cyan
    }

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .idle:
            IdleIslandContent()
        case .notification:
            if let activity = session.currentActivity {
                NotificationIslandContent(activity: activity)
            }
        case .expanded, .dragging:
            if let activity = session.currentActivity {
                ExpandedIslandContent(
                    activity: activity,
                    dragOffset: CGFloat(session.dragOffset),
                    threshold: threshold
                )
            }
        case .accepted, .denied:
            if let decision = session.lastDecision {
                ConfirmationIslandContent(decision: decision)
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                onDragChanged(value.translation.width)
            }
            .onEnded { value in
                onDragEnded(value.translation.width)
            }
    }
}

private struct IslandLayout {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let contentPadding: CGFloat
}

private struct IdleIslandContent: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(TerminalNoirTheme.cyan.opacity(0.35))
                .frame(width: 26, height: 6)
                .scaleEffect(x: pulse ? 1.0 : 0.82, y: 1.0)

            Circle()
                .fill(TerminalNoirTheme.cyan.opacity(0.8))
                .frame(width: 6, height: 6)
                .shadow(color: TerminalNoirTheme.cyan.opacity(0.35), radius: 6)

            Capsule()
                .fill(TerminalNoirTheme.border.opacity(0.9))
                .frame(width: 38, height: 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

private struct NotificationIslandContent: View {
    let activity: MonitorActivity

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(TerminalNoirTheme.cyan.opacity(0.12))
                Image(systemName: activity.appSymbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TerminalNoirTheme.cyan)
            }
            .frame(width: 24, height: 24)

            Text(activity.intent)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("MON")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.cyan.opacity(0.9))
                .tracking(1.4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ExpandedIslandContent: View {
    let activity: MonitorActivity
    let dragOffset: CGFloat
    let threshold: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(TerminalNoirTheme.cyan.opacity(0.12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(TerminalNoirTheme.border, lineWidth: 1)
                        }

                    Image(systemName: activity.appSymbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(TerminalNoirTheme.cyan)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.appName.uppercased())
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(TerminalNoirTheme.muted)
                        .tracking(1.6)

                    Text(activity.intent)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundStyle(TerminalNoirTheme.text)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                RiskBadge(risk: activity.risk)
            }

            ActivityScenePreview(activity: activity)
                .frame(height: 162)

            Text(activity.reason)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.muted)
                .lineSpacing(3)

            SwipeHintView(
                dragOffset: dragOffset,
                threshold: threshold
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct RiskBadge: View {
    let risk: MonitorActivity.RiskLevel

    private var tint: Color {
        switch risk {
        case .low:
            return TerminalNoirTheme.lime
        case .medium:
            return Color(hex: 0xFFC107)
        case .high:
            return TerminalNoirTheme.red
        }
    }

    var body: some View {
        Text(risk.badgeText)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundStyle(tint)
            .tracking(1.1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(tint.opacity(0.28), lineWidth: 1)
            }
    }
}

private struct SwipeHintView: View {
    let dragOffset: CGFloat
    let threshold: CGFloat

    private var clampedProgress: CGFloat {
        max(-1, min(1, dragOffset / threshold))
    }

    var body: some View {
        HStack(spacing: 10) {
            SwipeDirectionView(
                title: "BLOCK",
                symbol: "xmark",
                tint: TerminalNoirTheme.red
            )

            GeometryReader { proxy in
                let inset: CGFloat = 12
                let travel = (proxy.size.width - inset * 2 - 20) / 2

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(TerminalNoirTheme.border.opacity(0.5))
                        .frame(height: 4)

                    Circle()
                        .fill(TerminalNoirTheme.text)
                        .frame(width: 20, height: 20)
                        .shadow(color: TerminalNoirTheme.cyan.opacity(0.32), radius: 10)
                        .offset(x: travel + clampedProgress * travel)
                }
                .padding(.horizontal, inset)
            }
            .frame(height: 24)

            SwipeDirectionView(
                title: "ALLOW",
                symbol: "checkmark",
                tint: TerminalNoirTheme.lime
            )
        }
    }
}

private struct SwipeDirectionView: View {
    let title: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.14))
                    .overlay {
                        Circle()
                            .stroke(tint.opacity(0.28), lineWidth: 1)
                    }

                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tint)
            }
            .frame(width: 34, height: 34)

            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(tint.opacity(0.9))
        }
    }
}

private struct ConfirmationIslandContent: View {
    let decision: MonitorDecision

    private var tint: Color {
        switch decision {
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
                .frame(width: 22, height: 22)
                .overlay {
                    Image(systemName: decision.symbolName)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(decision == .allow ? Color.black : Color.white)
                }

            Text(decision.rawValue)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.text)
                .tracking(1.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
