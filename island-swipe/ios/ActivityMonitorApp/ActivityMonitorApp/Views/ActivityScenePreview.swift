import SwiftUI

struct ActivityScenePreview: View {
    let activity: MonitorActivity

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(sceneBackground)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(TerminalNoirTheme.border, lineWidth: 1)

            sceneContent
                .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var sceneBackground: LinearGradient {
        switch activity.scene {
        case .browser:
            return LinearGradient(
                colors: [Color(hex: 0x0D1520), Color(hex: 0x101D2A)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .terminal:
            return LinearGradient(
                colors: [Color(hex: 0x050A10), Color(hex: 0x081019)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .mail:
            return LinearGradient(
                colors: [Color(hex: 0x091019), Color(hex: 0x0B1520)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .code:
            return LinearGradient(
                colors: [Color(hex: 0x0A1018), Color(hex: 0x101927)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .chat:
            return LinearGradient(
                colors: [Color(hex: 0x0A1520), Color(hex: 0x081018)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .social:
            return LinearGradient(
                colors: [Color(hex: 0x060C12), Color(hex: 0x09111B)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    @ViewBuilder
    private var sceneContent: some View {
        switch activity.scene {
        case .browser:
            BrowserScenePreview()
        case .terminal:
            TerminalScenePreview()
        case .mail:
            MailScenePreview()
        case .code:
            CodeScenePreview()
        case .chat:
            ChatScenePreview()
        case .social:
            SocialScenePreview()
        }
    }
}

private struct BrowserScenePreview: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(Color.white.opacity(0.18)).frame(width: 7, height: 7)
                Circle().fill(Color.white.opacity(0.18)).frame(width: 7, height: 7)
                Circle().fill(Color.white.opacity(0.18)).frame(width: 7, height: 7)

                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(TerminalNoirTheme.surface.opacity(0.9))
                    .overlay(alignment: .leading) {
                        Text("youtube.com")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(TerminalNoirTheme.muted)
                            .padding(.leading, 8)
                    }
            }
            .frame(height: 22)

            HStack(spacing: 8) {
                SceneCardPlaceholder()
                SceneCardPlaceholder()
            }

            HStack(spacing: 8) {
                SceneCardPlaceholder()
                SceneCardPlaceholder()
            }
        }
    }
}

private struct TerminalScenePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("~/app $ ls")
                .foregroundStyle(TerminalNoirTheme.text)

            Text("node_modules/  src/  package.json")
                .foregroundStyle(TerminalNoirTheme.muted)

            HStack(spacing: 0) {
                Text("~/app $ ")
                    .foregroundStyle(TerminalNoirTheme.text)
                Text("rm -rf node_modules")
                    .foregroundStyle(TerminalNoirTheme.red)
                    .padding(.horizontal, 2)
                    .background(TerminalNoirTheme.red.opacity(0.18))
            }
        }
        .font(.system(size: 11, weight: .medium, design: .monospaced))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct MailScenePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(TerminalNoirTheme.surface.opacity(0.85))
                .frame(height: 28)
                .overlay(alignment: .leading) {
                    Text("To: recruiting@anthropic.com")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(TerminalNoirTheme.muted)
                        .padding(.leading, 10)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text("Dear hiring team,")
                    .foregroundStyle(TerminalNoirTheme.text)

                Text("I wanted to follow up on the role...")
                    .foregroundStyle(TerminalNoirTheme.muted)

                Text("|")
                    .foregroundStyle(TerminalNoirTheme.cyan)
            }
            .font(.system(size: 11, weight: .medium, design: .monospaced))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct CodeScenePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                codeText("function ", color: TerminalNoirTheme.text)
                codeText("verify", color: TerminalNoirTheme.cyan)
                codeText("(token) {", color: TerminalNoirTheme.text)
            }

            codeText("  if (!token) return null", color: TerminalNoirTheme.text)
            codeText("  // cursor here", color: TerminalNoirTheme.muted)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(TerminalNoirTheme.cyan.opacity(0.08), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .font(.system(size: 10, weight: .medium, design: .monospaced))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func codeText(_ value: String, color: Color) -> Text {
        Text(value)
            .foregroundStyle(color)
    }
}

private struct ChatScenePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("#dm · @liuwei")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(TerminalNoirTheme.muted)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(TerminalNoirTheme.surface.opacity(0.88))
                .overlay(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("wanna grab drinks after work?")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(TerminalNoirTheme.text)

                        Text("|")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(TerminalNoirTheme.cyan)
                    }
                    .padding(.horizontal, 10)
                }
                .frame(height: 42)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct SocialScenePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(TerminalNoirTheme.surface.opacity(0.9))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(TerminalNoirTheme.red.opacity(0.35), lineWidth: 1)
                }
                .frame(height: 64)
                .overlay(alignment: .leading) {
                    Text("Heard our next quarter strategy... [182 chars]")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(TerminalNoirTheme.text)
                        .padding(.horizontal, 10)
                }

            HStack {
                Spacer()
                Text("Post →")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(TerminalNoirTheme.cyan)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct SceneCardPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(TerminalNoirTheme.surface.opacity(0.72))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(TerminalNoirTheme.border.opacity(0.7), lineWidth: 1)
            }
            .frame(height: 46)
    }
}
