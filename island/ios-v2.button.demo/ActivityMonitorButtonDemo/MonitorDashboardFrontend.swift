import SwiftUI

struct MonitorDashboardView: View {
    @StateObject private var backend = MonitorDashboardBackend()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ZStack {
                MonitorBackdrop(reduceMotion: reduceMotion)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        commandHeader
                        requestPanel
                        decisionDock
                        statusStrip
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 26)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task {
                await backend.runRecordingDemoIfNeeded()
            }
        }
    }

    private var commandHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Activity Monitor")
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text("Dynamic Island permission desk")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.64))
                }

                Spacer(minLength: 12)

                DecisionBadge(decision: backend.currentState.decision)
            }

            HStack(spacing: 10) {
                MetricTile(title: "REQUEST", value: backend.currentState.riskLevel, tint: .orange)
                MetricTile(title: "SURFACE", value: backend.hasLiveActivity ? "LIVE" : "READY", tint: .cyan)
                MetricTile(title: "STATE", value: backend.currentState.decision.rawValue, tint: backend.currentState.decision.tint)
            }
        }
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var requestPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.10), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: 0.68)
                        .stroke(.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-92))
                    VStack(spacing: 1) {
                        Text(backend.currentState.riskLevel)
                            .font(.caption.weight(.black))
                        Text("RISK")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .foregroundStyle(.white)
                }
                .frame(width: 74, height: 74)

                VStack(alignment: .leading, spacing: 6) {
                    Label(backend.currentState.requester, systemImage: "lock.shield.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Permission request")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.orange)
                        .textCase(.uppercase)
                }
            }

            Text(backend.currentState.actionSummary)
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(.white)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "sparkles.rectangle.stack.fill")
                Text("Expanded Dynamic Island exposes the final ALLOW/BLOCK controls.")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white.opacity(0.60))
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.07, green: 0.083, blue: 0.095))
        }
        .overlay(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(backend.currentState.decision.tint.opacity(0.28), lineWidth: 1)
        }
    }

    private var decisionDock: some View {
        VStack(spacing: 12) {
            Button {
                backend.startLiveActivity()
            } label: {
                Label("Start Live Activity", systemImage: "dot.radiowaves.left.and.right")
                    .font(.headline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .accessibilityLabel("Start Live Activity")

            HStack(spacing: 12) {
                DecisionButton(title: "BLOCK", systemImage: "xmark.shield.fill", tint: .red) {
                    backend.decide(.blocked)
                }
                DecisionButton(title: "ALLOW", systemImage: "checkmark.shield.fill", tint: .green) {
                    backend.decide(.allowed)
                }
            }
        }
    }

    private var statusStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Status", systemImage: "waveform.path.ecg")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(backend.currentState.updatedAt, style: .time)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.54))
            }
            Text(backend.statusLine)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.76))
                .fixedSize(horizontal: false, vertical: true)
            Text("Last stored decision: \(backend.lastDecisionSummary)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.48))
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MonitorBackdrop: View {
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            Color(red: 0.018, green: 0.022, blue: 0.027)
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.08, blue: 0.045),
                    Color(red: 0.018, green: 0.022, blue: 0.027),
                    Color(red: 0.02, green: 0.07, blue: 0.075)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            TimelineView(.animation(minimumInterval: 2.5, paused: reduceMotion)) { timeline in
                let pulse = reduceMotion ? 0 : sin(timeline.date.timeIntervalSince1970) * 0.04
                Circle()
                    .fill(.cyan.opacity(0.10 + pulse))
                    .blur(radius: 52)
                    .frame(width: 210, height: 210)
                    .offset(x: 130, y: -230)
            }
        }
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(.white.opacity(0.42))
            Text(value)
                .font(.caption.weight(.black))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct DecisionBadge: View {
    let decision: ActivityMonitorAttributes.Decision

    var body: some View {
        Image(systemName: decision == .allowed ? "checkmark.shield.fill" : "lock.shield.fill")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.white, decision.tint)
            .frame(width: 52, height: 52)
            .background(decision.tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .accessibilityLabel("Decision \(decision.rawValue)")
    }
}

private struct DecisionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline.weight(.black))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .foregroundStyle(.white)
        .background(tint.opacity(0.22), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.42), lineWidth: 1)
        }
        .scaleEffect(1)
        .accessibilityLabel(title)
    }
}
