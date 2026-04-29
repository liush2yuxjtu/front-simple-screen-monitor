# Design · Graphite Mint

Version name: `graphite-mint`
Status: `DRAFT_OPTION_BATCH_01_2026-04-28`

## Core

- Mood: 系统工具、冷静、精密但不冷血。
- Best for: 想保留高级感，同时避免现在这版过度 web-demo 感。
- Risk: 如果文案不够锋利，会显得太保守。

## Palette

- Background: graphite `#151817`
- Surface: iron glass `#212725`
- Accent: mint `#8ec3a1`
- Support: chalk `#eef2ea`

## Layout

- 顶部时间和信号区更收敛，把重心让给主卡。
- 主卡里加入微型统计条，说明 AI 不是拍脑袋。
- detail sheet 更像系统 inspection panel。

## Motion

- 所有动效都压在 250 到 320ms 之间。
- 不做夸张旋转，卡片只做少量倾角。
- toast 像系统状态条，不像营销型浮层。

## SwiftUI Mapping

- `StatusBarView` 和 `HeaderView` 需要合并得更紧。
- `ActionProposalCard` 内部用 metric row 替代一部分长解释。
- `ToastView` 改成薄条状态带。

## Why Choose It

- 实施风险低，容易直接落成原生 SwiftUI 成品。
- 看起来会比现在更成熟、更像系统级 app。
