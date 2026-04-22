# 屏察御史 · Screen Monitor UX Lab

Backend snaps screen every 5s, guesses user intent, frontend asks for royal consent. Same consent prompt rendered in **three** distinct interaction paradigms.

## Live

https://liush2yuxjtu.github.io/front-simple-screen-monitor/

## Three chambers

| Path | 中文 | English | UI pattern |
|------|------|---------|------------|
| [`/`](./index.html) | 殿前 | Landing | Directory + hover previews |
| [`/swipe/`](./swipe/) | 御前羊皮卷 | Royal Parchment | Full-screen 3-column, scroll unfurls, swipe + vibrate on mobile |
| [`/popout/`](./popout/) | 密函天降 | Popout Envelope | Corner bell toast, tap opens letter modal, fly-away on verdict |
| [`/island/`](./island/) | 灵动岛御批 | Dynamic Island | Apple-style morphing pill, iOS buttons, device frame on desktop |
| [`/island-swipe/`](./island-swipe/) | 灵动岛滑驱 | Swipe Island | Same pill, swipe left=burn, swipe right=seal, no buttons |

All three share:

- Same mock `REQUEST_POOL` (Chrome / Terminal / Mail / VS Code / Slack / Twitter scenarios)
- Approve → red wax seal · Reject → burn/eject
- `navigator.vibrate(40)` on approve, `[80, 40, 80]` on reject
- Hotkeys: `A` seal · `D` burn · `SPACE` summon · `ESC` close (where relevant)

## Hosting

Static HTML, no build step. Google Fonts CDN with cross-platform Chinese fallback. GitHub Pages serves the repo root.
