# Design · Quiet Grid

Version name: `quiet-grid`
Status: `DRAFT_OPTION_BATCH_02_2026-04-28`

## Core

- Mood: 安静、理性、模块化。
- Best for: 喜欢明确结构和信息块的用户。
- Risk: 如果网格感太强，会失去轻松度。

## Palette

- Background: stone paper `#e2ddd4`
- Surface: chalk `#f5f2eb`
- Accent: sage line `#86936a`
- Support: slate brown `#504b45`

## Layout

- 把 Sand Signal 进一步做成轻格板。
- 当前动作、优先级、原因被切成小块。
- detail 区像延伸模块，而不是说明段落。

## Motion

- 卡片移动像对齐到下一个格点。
- 动画节奏要短、稳、少。
- 不做任何多余反弹。

## SwiftUI Mapping

- `ActionProposalCard` 适合用 grid row 重构。
- `MetricRow` 能成为一等公民。
- 对 macOS 扩展也更自然。

## Why Choose It

- 是最理性的白天方案。
- 适合希望“看一眼就知道结构”的用户。
