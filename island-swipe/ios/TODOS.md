# iOS App · TODOs / Resolved Follow-ups

Recorded during `/plan-eng-review` on 2026-04-23.

## TODO-1: Distribution pipeline (TestFlight + signing)

**What:** Set up Apple code signing, provisioning profiles, TestFlight upload,
fastlane lane or GitHub Actions workflow for `.ipa` builds.

**Why:** Prototype currently runs only on Simulator. No distribution channel = no
real-device validation, no external demo share.

**Pros:**
- Enables real-device haptic / gesture validation (simulator haptics are stubs).
- Unlocks external demo / stakeholder review.
- Forces clean signing config before it's urgent.

**Cons:**
- Apple Developer Program fee ($99/yr).
- Certificate + provisioning upkeep.
- Fastlane / GitHub Actions config surface area.

**Context:**
- `project.yml` and `ActivityMonitorApp.xcodeproj` currently lack team/bundle-id.
- No CI. No release automation.
- Plan explicitly scoped prototype-only (see Scope decision, eng review 2026-04-23).

**Depends on / blocked by:** Apple Developer Program enrollment.

---

## DONE-2: State persistence across launches

**Status:** Done on 2026-04-23.

**What:** Persist `MonitorSessionState.history`, `allowedCount`, `blockedCount`
across app launches via a `UserDefaults` JSON snapshot.

**Why:** Demo users may expect their decisions to persist across a cold-start.
Also required as data foundation for any future analytics / streak / trend
feature.

**Pros:**
- Session continuity UX.
- Foundation for later stats / trend features.
- Forces `Codable` completeness on the domain model.

**Cons:**
- New dependency surface (`UserDefaults` or Core Data).
- Schema migration becomes a concern once shipped.
- Testing surface expands.

**Context:**
- `MonitorActivity`, `MonitorDecision`, `RiskLevel`, `SceneKind`, and
  `MonitorHistoryEntry` now conform to `Codable`.
- `MonitorSessionStore` stores only counters and history, intentionally leaving
  current activity, phase, drag offset, and last decision transient.
- `MonitorViewModel.bootstrap()` restores the snapshot; completed decisions save
  the snapshot before the next activity cycle.
- XCTest covers snapshot restoration and `UserDefaults` round-trip.

**Depends on / blocked by:** Complete.

---

## TODO-3: Accessibility pass (real-device VoiceOver + large text QA)

**What:** Complete the remaining accessibility pass. Baseline VoiceOver labels,
hints, values, custom Allow / Block actions, and Dynamic Type-aware monospaced
text now exist for the core monitor flow; remaining work is deeper VoiceOver QA,
real-device gesture testing, and any large-text layout tuning found there.

**Why:** The core flow is no longer swipe-only and no longer fixed-size-only,
but App Store review and any public distribution still require real assistive
technology validation rather than simulator-only spot checks.

**Pros:**
- Reaches users with motor / visual impairments.
- Reduces App Store rejection risk.
- Dynamic Type support also helps users who simply prefer larger text.

**Cons:**
- Real VoiceOver QA requires a signed device build for the most reliable pass.
- Very large Dynamic Type sizes can force truncation or additional scrolling in
  the fixed-height Dynamic-Island-style surface.
- Design + engineering lift remains non-trivial if QA finds rotor/focus-order
  issues.

**Context:**
- `DynamicIslandMonitorView` exposes VoiceOver labels, hints, values, and
  custom Allow / Block actions as a non-swipe path.
- Stats, history, and hint panels now provide combined accessibility labels.
- Typography now goes through `terminalFont(...)`, which preserves the
  monospaced aesthetic while scaling with Dynamic Type via `@ScaledMetric`.
- Simulator screenshots were checked at `large` and `accessibility-large`
  content sizes; real-device VoiceOver and Dynamic Type QA still required.

**Depends on / blocked by:** None. Best done before public distribution
(see TODO-1).
