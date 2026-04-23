# iOS App Plan · ActivityMonitorApp

Source of truth: [`island-swipe/DESIGN.md`](../DESIGN.md)
Target: native SwiftUI iPhone app at `island-swipe/ios/ActivityMonitorApp/`

## Codex exec prompt

Run verbatim from repo root to (re)generate / iterate the app:

```bash
codex exec 'Read island-swipe/DESIGN.md and implement a native SwiftUI iPhone app based on it.

Important product decision:
- This is a real iPhone app built with SwiftUI
- The main experience should live inside the app UI
- Do NOT treat this as a web page
- Do NOT fake it as HTML
- Build an in-app "Dynamic Island style" interaction at the top of the screen, visually inspired by Dynamic Island, but implemented inside the app interface

Design source of truth:
- Follow island-swipe/DESIGN.md strictly
- Preserve the exact concept: high-tech Dynamic Island screen activity monitor
- Preserve the exact visual direction: Terminal Noir
- No 中二 metaphors
- Use only functional language such as ALLOW / BLOCK / MONITOR / APPROVE / DENY

Visual requirements:
- Full-screen dark interface
- Top area contains a Dynamic-Island-style pill component
- Main background uses #04080f
- Phone/surface feel uses #0a1520
- Cyan accent #00e5ff
- Lime approval #76ff03
- Red denial #ff1744
- Primary text #e0f7fa
- Muted text #4a6a7a
- Border #1a3a4a
- Typography should feel monospace / technical / precise
- If custom fonts are inconvenient, choose the closest native fallback while preserving the intended feel

Core UI:
- Title: 灵动岛 · Activity Monitor
- Subtitle: Swipe to decide · Left = BLOCK · Right = ALLOW
- Stats panel below with ALLOWED / BLOCKED / TOTAL
- Dynamic-Island-style notification card appears in the top pill area
- Swipe hint arrows shown inside the expanded island component

Interaction requirements:
- Left swipe beyond 90pt threshold = BLOCK
- Right swipe beyond 90pt threshold = ALLOW
- Red visual feedback for BLOCK
- Green/lime visual feedback for ALLOW
- Auto-expand 1.2s after a notification appears
- Update counters live after each decision
- Add haptic feedback on successful decision if supported
- Animations should feel polished, restrained, precise, and futuristic
- Avoid clutter and over-decoration

Engineering requirements:
- Use SwiftUI as primary UI framework
- Organize code cleanly into reusable components
- Separate:
  1. app shell
  2. island component
  3. swipe gesture logic
  4. stats panel
  5. state/data model
  6. haptic utility
- Provide sample activity items so the prototype is fully interactive on first launch
- Make the UI work well on modern iPhone sizes
- Support dark appearance as the intended default

Implementation preference:
- Build this as a polished app prototype, not just a static mock
- Prioritize high-quality motion, spacing, hierarchy, contrast, and interaction feel
- Keep the design disciplined and minimal
- No fantasy metaphors, no ceremonial language, no gimmicks

Before finishing:
1. self-review against every section of island-swipe/DESIGN.md
2. verify swipe threshold behavior
3. verify counters update correctly
4. verify the island auto-expands after 1.2s
5. verify haptics are triggered on completed swipe if available
6. fix any rough edges found

Finally, summarize what you implemented and any small compromises you made.'
```

## Non-negotiables

- Native SwiftUI. Not WebView. Not HTML.
- Terminal Noir palette exact (hex above).
- Functional copy only. No 中二 metaphor.
- Swipe threshold = 90pt.
- Auto-expand = 1.2s.
- Haptic on completed decision.
- All timing constants (auto-expand, bootstrap, reset/present delays, spring
  response/damping) live in a single `Timings` / `AnimationTokens` module.
  No numeric literals in ViewModels or Views for timing.
- Swift 6 strict-concurrency clean: `@MainActor` classes must use
  `nonisolated(unsafe)` for Task handles accessed from `deinit`.
- State-machine mutations NOT wrapped in `withAnimation`: separate pure state
  transitions from phase-driven visual animation.

## Target module layout

```
ActivityMonitorApp/
├─ ActivityMonitorApp.swift   # app shell
├─ Core/                      # state machine, data model
├─ ViewModels/                # MonitorViewModel
├─ Views/                     # DynamicIslandMonitorView, StatsPanelView, ActivityScenePreview
├─ Support/                   # HapticsClient, swipe gesture helpers
├─ Theme/                     # color tokens, typography
└─ Resources/                 # assets
```

## Acceptance gates

1. Swipe left past 90pt → BLOCK counter +1, red flash, haptic.
2. Swipe right past 90pt → ALLOW counter +1, lime flash, haptic.
3. Island collapsed → 1.2s after new item → auto-expand.
4. TOTAL = ALLOWED + BLOCKED always.
5. Dark appearance default. No light-mode regression.
6. Runs on iPhone 15 / 15 Pro sim, iOS 17+.

Gates 1, 2, and 4 are covered by
`ActivityMonitorAppTests/MonitorSessionStateTests.swift`; the same suite also
covers the phase guard for non-swipe decision actions.
Gates 3 and 5 were visually verified in Simulator after launching the app.
Gate 6 verified locally on available Simulator runtime:
`xcodebuild test -project island-swipe/ios/ActivityMonitorApp.xcodeproj -scheme ActivityMonitorApp -destination 'platform=iOS Simulator,name=iPhone 16'`.
The local machine does not currently expose an iPhone 15 / 15 Pro simulator;
available phone coverage is iPhone 16 on iOS 18.6.

## What already exists

As of eng review (2026-04-23), implementation at `ActivityMonitorApp/` covers:

- `Core/MonitorStateMachine.swift` — pure `MonitorSessionState` with
  `IslandPhase` enum, `commitDecision`, history cap=6.
- `Core/MonitorActivity.swift` — domain model + `MonitorDecision` enum.
- `Core/ActivityCatalog.swift` — 6 sample activities covering all 6 scene kinds.
- `ViewModels/MonitorViewModel.swift` — `@MainActor` controller, haptic-arm
  tracking, auto-expand / reset cycles.
- `Views/DynamicIslandMonitorView.swift` — island container + 4 phase content
  views (idle / notification / expanded / confirmation) + swipe hint slider.
- `Views/MonitorDashboardView.swift` — dashboard shell with Terminal Noir
  backdrop (grid canvas).
- `Views/StatsPanelView.swift`, `Views/HistoryPanelView.swift`,
  `Views/HintPanelView.swift`, `Views/ActivityScenePreview.swift` — secondary
  panels.
- `Support/HapticsClient.swift` — UIKit-gated `play` / `tick` / `cancel`.
- `Theme/TerminalNoirTheme.swift` — color tokens, Dynamic Type-aware
  monospace typography helper, hex-init Color extension.
- `ActivityMonitorAppTests/MonitorSessionStateTests.swift` — XCTest coverage
  for left/right threshold commits, below-threshold reset, total invariant,
  decision overshoot, and history cap.

Plan's proposed `Resources/` directory is not used; no asset shipped yet.

## NOT in scope (explicitly deferred)

- **CI pipeline (GitHub Actions).** Local `xcodebuild test` now works, but no
  remote CI workflow is configured yet.
- **Distribution (TestFlight / code signing / fastlane).** Simulator-only.
  Real-device validation of haptics requires signing. See `TODOS.md` TODO-1.
- **State persistence across launches.** Counters + history in-memory only.
  See `TODOS.md` TODO-2.
- **Full accessibility certification.** Baseline VoiceOver labels, values,
  hints, non-swipe decision actions, and Dynamic Type-aware typography are in
  place. Real-device VoiceOver QA and deeper large-text tuning remain deferred.
  See `TODOS.md` TODO-3.
- **Localization.** Strings `ALLOW` / `BLOCK` / `MONITOR` hardcoded English;
  title is mixed zh/en literal. Acceptable for prototype demo.

## Review decisions (2026-04-23 eng review)

Resolved in current refinement branch:

1. **DONE: Split `nextCycleTask` into `resetTask` + `presentTask`** — eliminate
   bootstrap × decision race in `MonitorViewModel.scheduleResetAfterDecision`.
2. **DONE: Separate state commit from animation** — call
   `session.commitDecision(...)` outside `withAnimation`; wrap only the
   post-commit visual trigger.
3. **DONE: Extract `Timings` enum** — move `1.2s auto-expand`, `0.45s bootstrap`,
   `0.9s reset clear`, `0.5s next-activity delay` to a single module.
4. **DONE: Mark Task handles `nonisolated(unsafe)`** — Swift 6 strict-concurrency
   readiness for `MonitorViewModel` `deinit`.
5. **DONE: Extract `AnimationTokens`** — 8 scattered spring
   `(response, dampingFraction)` pairs → named animations
   (e.g. `.islandOpen`, `.dragResponsive`, `.decisionPop`).
6. **DONE: Name `decisionOvershoot = 132`** — replace magic literal in
   `MonitorSessionState.apply`.
7. **DONE: Cache Terminal Noir grid** — apply `.drawingGroup()` on `Canvas` or
   render once into cached `Image` to avoid per-frame stride redraw.

## GSTACK REVIEW REPORT

| Review        | Trigger              | Why                             | Runs | Status                | Findings                     |
|---------------|----------------------|---------------------------------|------|-----------------------|------------------------------|
| CEO Review    | `/plan-ceo-review`   | Scope & strategy                | 0    | —                     | —                            |
| Codex Review  | `/codex review`      | Independent 2nd opinion         | 0    | —                     | — (declined inline)          |
| Eng Review    | `/plan-eng-review`   | Architecture & tests (required) | 1    | resolved_local         | 7 issues resolved + tests    |
| Design Review | `/plan-design-review`| UI/UX gaps                      | 1    | local_manual_partial    | 2 fixed, accessibility baseline added |
| DX Review     | `/plan-devex-review` | Developer experience gaps       | 0    | —                     | —                            |

**UNRESOLVED:** 0 — all 7 findings reached a decision and were implemented.
**VERDICT:** ENG resolved_local — refactor queue completed; local Simulator
build, launch, screenshot, and XCTest verification passed. Remote CI,
distribution, persistence, and full real-device accessibility QA remain
deferred.

## Local design review (2026-04-23)

The scripted `/plan-design-review` entrypoint was not available in this
environment, so this pass used the Simulator run and recorded demo video at
`/Users/liushiyu/Movies/activity-monitor-demo-final-2026-04-23.mp4`.

**Verdict:** Visual direction is coherent and demo-ready. Terminal Noir palette,
functional copy, Dynamic-Island-style pill, and swipe affordance all match
`island-swipe/DESIGN.md`. No blocker for prototype/demo.

Follow-up polish implemented after this pass:

- First-run idle pill now shows explicit `MONITORING` copy instead of abstract
  capsules.
- Expanded island now includes a visible `DRAG TO DECIDE` affordance above the
  swipe rail.
- Core monitor flow now exposes VoiceOver label/value/hint text plus custom
  `Allow` / `Block` actions, guarded to notification/expanded/dragging phases.
- Monospaced typography now uses `@ScaledMetric` through `terminalFont(...)`;
  Simulator screenshots were checked at `large` and `accessibility-large`
  content sizes.

Follow-up polish queue:

1. **DONE: First-run idle state is visually under-explained.** The idle island
   now shows `MONITORING` before the first activity appears.
2. **DONE: Swipe affordance depends on reading small helper text.** The
   expanded island now labels the control with `DRAG TO DECIDE`.
3. **PARTIAL: Accessibility and Dynamic Type remain the major design debt.**
   VoiceOver labels, hints, values, custom Allow / Block actions, and
   Dynamic Type-aware monospaced typography now cover the core flow. Very-large
   text tuning and real-device VoiceOver QA remain before public distribution.
   This aligns with `TODOS.md` TODO-3.
