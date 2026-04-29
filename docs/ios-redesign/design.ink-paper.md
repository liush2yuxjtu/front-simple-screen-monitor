# Design · Ink Paper

Version name: `ink-paper`
Status: `DRAFT_OPTION_BATCH_01_2026-04-28`

## Core

- Mood: 编辑台、批注、可读性优先。
- Best for: 让 AI 判断看起来更可信、更可审阅。
- Risk: 侵略性最弱，演示冲击力不如深色方案。

## Palette

- Background: rice paper `#f3ecde`
- Surface: warm white `#fbf7ef`
- Accent: ink red `#b84f3e`
- Support: brush black `#2d2723`

## Layout

- 整个锁屏像一张高质量便笺，不像夜间系统。
- 引用区做成纸条堆叠，行动标题像编辑批注。
- detail sheet 就地展开，像旁批，不像 modal。

## Motion

- 动效最轻，更多依赖层级、位移和纸面错位。
- 上滑 detail 是纸张翻起，而不是玻璃抽屉。
- 执行成功只做轻微色带推进。

## SwiftUI Mapping

- 允许 `preferredColorScheme` 不锁死深色。
- `ActionProposalCard` 里的 quote block 改为浅色纸片。
- `GestureHintBar` 变成下沿纸签。

## Why Choose It

- 如果你想让产品更像“认知助手”而不是“警报系统”，选它。
- 这套最利于后面加更多解释文本和 reasoning 细节。
