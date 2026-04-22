codex exec 'Read island-swipe/DESIGN.md and implement a native macOS app in SwiftUI based on it.

Important product decision:
- This is a real macOS app built with SwiftUI
- Do NOT treat this as a web page
- Do NOT fake it as HTML
- Build a desktop app that presents the concept in a polished macOS window
- The main visual should be a centered iPhone mockup inside the macOS app window, preserving the original product concept

Design source of truth:
- Follow island-swipe/DESIGN.md strictly
- Preserve the exact concept: high-tech Dynamic Island screen activity monitor
- Preserve the exact visual direction: Terminal Noir
- No 中二 metaphors
- Use only functional language such as ALLOW / BLOCK / MONITOR / APPROVE / DENY

Visual requirements:
- Dark macOS app window with the main composition centered
- Full iPhone mockup shown prominently in the window
- Dynamic-Island-style pill at the top of the phone mockup
- Stats panel below the island area
- Main background uses #04080f
- Phone/surface feel uses #0a1520
- Cyan accent #00e5ff
- Lime approval #76ff03
- Red denial #ff1744
- Primary text #e0f7fa
- Muted text #4a6a7a
- Border #1a3a4a
- Typography should feel monospace / technical / precise
- If JetBrains Mono and Noto Sans SC are inconvenient, use the closest native fallback while preserving the intended feel

Core UI:
- Title: 灵动岛 · Activity Monitor
- Subtitle: Swipe to decide · Left = BLOCK · Right = ALLOW
- Stats panel with ALLOWED / BLOCKED / TOTAL
- Swipe hint arrows inside the expanded island component
- Maintain a clean futuristic system-monitor feel

Interaction requirements:
- Left swipe beyond 90pt threshold = BLOCK
- Right swipe beyond 90pt threshold = ALLOW
- Red visual feedback for BLOCK
- Green/lime visual feedback for ALLOW
- Auto-expand 1.2s after a notification appears
- Update counters live after each decision
- Support trackpad / mouse drag naturally on macOS
- Add haptic feedback if feasible on supported devices, otherwise degrade gracefully
- Animations should feel polished, restrained, precise, and futuristic
- Avoid clutter and over-decoration

Engineering requirements:
- Use SwiftUI as primary UI framework
- Build a real macOS app, ready to open and run in Xcode
- Organize code cleanly into reusable components
- Separate:
  1. app shell
  2. main window scene
  3. phone mockup container
  4. island component
  5. swipe gesture logic
  6. stats panel
  7. state/data model
  8. haptic utility if used
- Provide sample activity items so the prototype is fully interactive on first launch
- Make the window look polished on modern Mac displays
- Default to dark appearance or a dark-first visual treatment

Implementation preference:
- Build this as a polished native app prototype, not a static mock
- Prioritize high-quality motion, spacing, hierarchy, contrast, and interaction feel
- Keep the design disciplined and minimal
- No fantasy metaphors, no ceremonial language, no gimmicks

macOS-specific guidance:
- The app should feel native on macOS while preserving the iPhone-inspired visual concept
- Prefer a clean fixed or lightly resizable window with good default sizing
- Ensure drag gestures feel good with mouse and trackpad
- Do not introduce unnecessary toolbars or sidebars unless they materially improve the presentation

Before finishing:
1. self-review against every section of island-swipe/DESIGN.md
2. verify swipe threshold behavior
3. verify counters update correctly
4. verify the island auto-expands after 1.2s
5. verify the layout looks strong in a macOS app window
6. fix any rough edges found

Finally, summarize what you implemented and any small compromises you made.'
