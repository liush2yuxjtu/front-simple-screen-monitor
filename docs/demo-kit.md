# Demo Kit Completion Status

Plan D is `Boil the Lake Hybrid`: ship the complete hackathon demo kit first,
then treat live performance as an optional bonus.

When asked `what is Demo Kit status?`, answer from this document: Demo Kit is
`PUBLIC_DEMO_READY_HOSTED_SMOKE_PASS_READY_FOR_FULL_E2E`. The canonical
60-second recording verifies as `ship 12/12`, and GitHub Pages now serves the
Watch links plus the public MP4 asset.

## Status

Current Demo Kit status: `PUBLIC_DEMO_READY_HOSTED_SMOKE_PASS_READY_FOR_FULL_E2E`.

Current D status: `PUBLIC_DEMO_READY_HOSTED_SMOKE_PASS_READY_FOR_FULL_E2E`.

Current e2e status: `HOSTED_SMOKE_PASS_READY_FOR_FULL_E2E`.

Canonical local recording status: `COMPLETE`.

Canonical local self-verify status: `ship 12/12`.

Public video link status: `HOSTED_ASSET_200_VIDEO_MP4`.

Public video URL:
`https://liush2yuxjtu.github.io/front-simple-screen-monitor/assets/demo/activity-monitor-canonical-demo-2026-04-24T05-01-34.mp4`

Public asset path: `assets/demo/activity-monitor-canonical-demo-2026-04-24T05-01-34.mp4`.

Public asset size: `547,068 bytes`.

Current canonical local evidence:
- Video:
  `/Users/liushiyu/Movies/activity-monitor-canonical-demo-2026-04-24T05-01-34.mp4`
- Evidence:
  `/Users/liushiyu/Movies/activity-monitor-canonical-demo-2026-04-24T05-01-34.evidence.json`
- Current repo fixture:
  `docs/examples/video-feature-self-verify.demo-current.json`

What changed:
- `scripts/record-canonical-demo.mjs` produced a canonical local 60-second demo.
- The current self-verify fixture points at the canonical evidence and public
  MP4 URL.
- Non-strict and strict video self-verification both return `ship` with score
  `12/12`.
- Local files wire the public static MP4 into `README.md`, `/`, and
  `/island-swipe/`.
- Hosted probe on 2026-04-24 after push found the public MP4 URL returns
  `200 video/mp4`, and hosted root plus island-swipe pages contain the Watch
  link.
- The e2e status is now `HOSTED_SMOKE_PASS_READY_FOR_FULL_E2E`.

Completed:
- GitHub Pages serves the interactive fallback at `/` and `/island-swipe/`.
- The Terminal Noir swipe demo shows screen context, ALLOW, BLOCK, counters, and
  recent decisions.
- Video self-verification docs, fixtures, and CLI exist.
- Canonical local recording is complete and verified as `ship 12/12`.
- Public static MP4 is connected in local files for README, root page, and
  island-swipe page.
- Local QA on 2026-04-24 loaded `/`, `/island-swipe/`, and `/gallery/` with no
  console errors. Keyboard Space, ArrowRight, and ArrowLeft verified prompt,
  ALLOW counter, BLOCK counter, TOTAL counter, and recent decision updates.
- Text-only design review on 2026-04-24 rates the Demo Kit plan `8/10`.

Hosted deploy result:
- Full hosted e2e is ready to run next.
- Commit `958252d` was pushed to `origin/main`, and GitHub Pages serves the
  public MP4 plus Watch links.
- Live performance remains a fallback path, not a dependency.

## Next Plan

1. Run full hosted e2e against the deployed GitHub Pages URLs.
2. Re-run the current video self-verify commands after any evidence update.
3. Keep the public MP4 and Watch links unless canonical evidence changes.
4. Update docs with changed/run/verify/status before calling work done.

## 60-Second Script

Your AI assistant can see your screen. That is powerful, and dangerous.

Activity Monitor adds a permission layer. When AI wants to act, it appears as a
Dynamic-Island-style prompt.

Swipe right to ALLOW. Swipe left to BLOCK.

Every decision updates the trust log, so you can see what happened and why.

This is what OS permissions look like when AI stops being a chatbot and starts
acting on your computer.

## Shot List

1. 00:00-00:06: Show current screen activity before the first prompt.
2. 00:06-00:14: Permission prompt appears before AI action.
3. 00:14-00:23: Swipe right to ALLOW, hold green confirmation, show count +1.
4. 00:23-00:35: Show high-risk terminal or private-message request.
5. 00:35-00:44: Swipe left to BLOCK, hold red confirmation, show count +1.
6. 00:44-00:54: Show recent decisions / trust log matching the choices.
7. 00:54-01:00: Return to the next request and show the live link.

## Run It

Static local preview:

```bash
python3 -m http.server 4173
```

Then open:

```text
http://localhost:4173/
http://localhost:4173/island-swipe/
```

Public fallback:
`https://liush2yuxjtu.github.io/front-simple-screen-monitor/`

Public video:
`https://liush2yuxjtu.github.io/front-simple-screen-monitor/assets/demo/activity-monitor-canonical-demo-2026-04-24T05-01-34.mp4`

Hosted e2e after deploy:

```bash
curl -I -L https://liush2yuxjtu.github.io/front-simple-screen-monitor/
curl -I -L https://liush2yuxjtu.github.io/front-simple-screen-monitor/island-swipe/
curl -I -L https://liush2yuxjtu.github.io/front-simple-screen-monitor/assets/demo/activity-monitor-canonical-demo-2026-04-24T05-01-34.mp4
```

Record the canonical local demo:

```bash
node scripts/record-canonical-demo.mjs
```

## Verify It

Check the current canonical local evidence:

```bash
node scripts/video-feature-self-verify.mjs docs/examples/video-feature-self-verify.demo-current.json
node scripts/video-feature-self-verify.mjs --strict docs/examples/video-feature-self-verify.demo-current.json
```

Expected current verdict: `ship` with score `12/12`.

Hosted smoke after deploy: root page has the Watch link, island-swipe page has
the Watch link, and public MP4 returns `200 video/mp4`.

Finish-work probes: run the required docs rule, engineer completion,
recent-work, Demo Kit status, and e2e status `claudefast -p` prompts.

## QA And E2E Status

Latest local QA: `PASS_WITH_SCOPE_LIMITS`.

Latest e2e status for Demo Kit: `HOSTED_SMOKE_PASS_READY_FOR_FULL_E2E`.

Verified on 2026-04-24:
- `/` loads through local preview with no console errors.
- `/island-swipe/` loads with no console errors.
- Space expands the pill.
- ArrowRight records ALLOW and updates ALLOWED / TOTAL.
- ArrowLeft records BLOCK and updates BLOCKED / TOTAL.
- Mobile viewport `375x812` keeps text and controls readable.
- `/gallery/` loads and exposes variant links with no console errors.
- Local README, `/`, and `/island-swipe/` contain the Watch link.

Hosted probe before deploy on 2026-04-24:
- `https://liush2yuxjtu.github.io/front-simple-screen-monitor/` returned `200`.
- `https://liush2yuxjtu.github.io/front-simple-screen-monitor/island-swipe/`
  returned `200`.
- The canonical public MP4 URL returned `404`.
- Hosted pages did not include the new Watch link.

Hosted smoke after deploy on 2026-04-24:
- Root page contains `Watch: public video`.
- Island-swipe page contains `Watch: public video`.
- Canonical public MP4 returned `200`, `content-type: video/mp4`, and
  `content-length: 547068`.

Scope limits:
- This did not test real touch swipes, only keyboard equivalents.
- Full hosted e2e should run next now that GitHub Pages serves the public MP4
  asset and Watch links.

## Live Runbook

1. Open the public fallback or local preview before presenting.
2. Set browser zoom to 100%.
3. Start at `/island-swipe/`.
4. Let the pill expand.
5. Swipe right on a low-risk request.
6. Swipe left on the terminal `rm -rf node_modules` request.
7. Point to ALLOWED, BLOCKED, TOTAL, and RECENT DECISIONS.
8. If projection, pointer, or network fails, stop the live demo and play the
   canonical video.
