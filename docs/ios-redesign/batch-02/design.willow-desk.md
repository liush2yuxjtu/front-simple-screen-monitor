# Design · Willow Desk

Version name: `willow-desk`
Status: `DRAFT_OPTION_BATCH_02_2026-04-28`

## Core

- Mood: 桌面便签、工作草稿、柔和解释。
- Best for: 需要 reasoning、批注、上下文补充的动作。
- Risk: 手机上如果太满，会丢掉 Sand Signal 的清爽。

## Palette

- Background: willow paper `#e6ead9`
- Surface: desk card `#f9f7ef`
- Accent: willow green `#87976b`
- Support: cedar `#4e5547`

## Layout

- 主卡像工作台上的 note card。
- 次级说明区像贴边便签。
- detail 更像 desk memo，而不是 sheet。

## Motion

- 层与层之间只有轻微错位。
- 执行后只改变标签和色带。
- 依据区像抽出一张附笺。

## SwiftUI Mapping

- `ActionProposalCard` 允许附笺式 secondary panel。
- `DetailSheetView` 可内嵌于主卡下缘。
- 更适合后续加 reasoning 文案。

## Why Choose It

- 是 Sand Signal 里最利于解释的一支。
- 如果你想保留轻感同时增强“思考感”，它更合适。
