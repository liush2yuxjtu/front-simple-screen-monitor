# Design · Porcelain Dock

Version name: `porcelain-dock`
Status: `DRAFT_OPTION_BATCH_02_2026-04-28`

## Core

- Mood: 原生、安静、细致。
- Best for: 想把 Sand Signal 直接往 shipping 级 iOS UI 推。
- Risk: 个性最弱，容易显得太保守。

## Palette

- Background: porcelain `#efebe4`
- Surface: milk glass `#fbf8f2`
- Accent: sage gray `#92a08c`
- Support: graphite taupe `#5c5750`

## Layout

- 卡片边界更淡，靠间距而不是样式差异做层级。
- 底部 dock 更统一，更像系统工具条。
- detail 区像标准原生补充说明。

## Motion

- 缩放和透明度都压得很轻。
- 执行反馈像系统状态切换。
- 几乎没有戏剧性。

## SwiftUI Mapping

- 可直接对齐 iOS 原生 materials 和 toolbars。
- `ToastView` 可以收成内联状态标签。
- `GestureHintBar` 更像 dock。

## Why Choose It

- 落地风险最低。
- 如果目标是成品感而不是概念感，优先看它。
