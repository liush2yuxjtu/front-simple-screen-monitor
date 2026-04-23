import SwiftUI

struct MonitorDashboardView: View {
    @StateObject private var viewModel = MonitorViewModel()

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = min(proxy.size.width - 28, 390)

            ZStack {
                TerminalNoirBackdrop()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        DynamicIslandMonitorView(
                            session: viewModel.session,
                            threshold: viewModel.decisionThreshold,
                            availableWidth: min(contentWidth, 370),
                            onTapNotification: viewModel.expandNow,
                            onDragChanged: viewModel.updateDrag,
                            onDragEnded: viewModel.endDrag,
                            onDecisionRequested: viewModel.requestDecision
                        )
                        .padding(.top, max(proxy.safeAreaInsets.top + 8, 26))

                        VStack(spacing: 8) {
                            Text("灵动岛 · Activity Monitor")
                                .terminalFont(size: 18, weight: .semibold, relativeTo: .title3)
                                .foregroundStyle(TerminalNoirTheme.text)
                                .tracking(1.8)

                            Text("Swipe to decide · Left = BLOCK · Right = ALLOW")
                                .terminalFont(size: 11, weight: .medium, relativeTo: .footnote)
                                .foregroundStyle(TerminalNoirTheme.muted)
                                .tracking(1.2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: contentWidth)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Activity Monitor")
                        .accessibilityHint("Swipe activity cards left to block or right to allow.")

                        StatsPanelView(session: viewModel.session)
                            .frame(maxWidth: contentWidth)

                        HintPanelView()
                            .frame(maxWidth: contentWidth)

                        HistoryPanelView(entries: viewModel.session.history)
                            .frame(maxWidth: contentWidth)

                        Spacer(minLength: max(proxy.safeAreaInsets.bottom + 20, 28))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)
                }
            }
            .ignoresSafeArea()
            .task {
                viewModel.bootstrap()
            }
        }
    }
}

private struct TerminalNoirBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    TerminalNoirTheme.background,
                    TerminalNoirTheme.surface.opacity(0.94),
                    TerminalNoirTheme.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(TerminalNoirTheme.cyan.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 120)
                .offset(x: -110, y: -280)

            Circle()
                .fill(TerminalNoirTheme.lime.opacity(0.08))
                .frame(width: 240, height: 240)
                .blur(radius: 120)
                .offset(x: 130, y: 300)

            Canvas(rendersAsynchronously: false) { context, size in
                var vertical = Path()
                stride(from: 0.0, through: size.width, by: 40).forEach { x in
                    vertical.move(to: CGPoint(x: x, y: 0))
                    vertical.addLine(to: CGPoint(x: x, y: size.height))
                }

                var horizontal = Path()
                stride(from: 0.0, through: size.height, by: 40).forEach { y in
                    horizontal.move(to: CGPoint(x: 0, y: y))
                    horizontal.addLine(to: CGPoint(x: size.width, y: y))
                }

                context.stroke(vertical, with: .color(TerminalNoirTheme.cyan.opacity(0.035)), lineWidth: 0.5)
                context.stroke(horizontal, with: .color(TerminalNoirTheme.cyan.opacity(0.03)), lineWidth: 0.5)
            }
            .drawingGroup()
        }
    }
}
