import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct ActivityMonitorLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ActivityMonitorAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)
                .widgetURL(deepLinkURL(for: context))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 5) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(context.state.decision.tint)
                        Text(context.state.requester)
                            .lineLimit(1)
                    }
                    .font(.caption.weight(.bold))
                }

                DynamicIslandExpandedRegion(.trailing) {
                    WidgetPill("Risk \(context.state.riskLevel)", tint: .orange)
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text("AI ACTION REQUEST")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.secondary)
                        Text(context.state.actionSummary)
                            .font(.subheadline.weight(.bold))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        Text(context.state.decision.rawValue)
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(context.state.decision.tint)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        Button(intent: BlockRequestIntent(requestID: context.attributes.requestID)) {
                            Label("BLOCK", systemImage: "xmark.shield.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.red)

                        Button(intent: AllowRequestIntent(requestID: context.attributes.requestID)) {
                            Label("ALLOW", systemImage: "checkmark.shield.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.green)
                    }
                    .font(.caption.weight(.heavy))
                    .buttonStyle(.borderedProminent)
                }
            } compactLeading: {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(context.state.decision.tint)
            } compactTrailing: {
                Text(context.state.decision == .pending ? context.state.riskLevel : context.state.decision.rawValue.prefix(2).uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(context.state.decision.tint)
            } minimal: {
                Image(systemName: context.state.decision == .allowed ? "checkmark.shield.fill" : "shield.fill")
                    .foregroundStyle(context.state.decision.tint)
            }
            .widgetURL(deepLinkURL(for: context))
            .keylineTint(context.state.decision.tint)
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<ActivityMonitorAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Label(context.state.requester, systemImage: "lock.shield.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                WidgetPill(context.state.decision.rawValue, tint: context.state.decision.tint)
            }

            Text(context.state.actionSummary)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(2)

            HStack {
                WidgetPill("Risk \(context.state.riskLevel)", tint: .orange)
                Spacer()
                Text(context.state.updatedAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding(16)
        .background {
            LinearGradient(
                colors: [
                    Color(red: 0.09, green: 0.10, blue: 0.12),
                    Color(red: 0.01, green: 0.012, blue: 0.018)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct WidgetPill: View {
    let title: String
    let tint: Color

    init(_ title: String, tint: Color) {
        self.title = title
        self.tint = tint
    }

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.18), in: Capsule())
    }
}

private func deepLinkURL(for context: ActivityViewContext<ActivityMonitorAttributes>) -> URL? {
    URL(string: "activitymonitor://request/\(context.attributes.requestID)")
}

@main
struct ActivityMonitorWidgetBundle: WidgetBundle {
    var body: some Widget {
        ActivityMonitorLiveActivity()
    }
}
