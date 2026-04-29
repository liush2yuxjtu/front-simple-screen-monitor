# Design · Copper Grid

Version name: `copper-grid`
Status: `DRAFT_OPTION_BATCH_01_2026-04-28`

## Core

- Mood: 硬件仪表、执行链路、工业控制面板。
- Best for: 想强调 agent 是在处理任务队列，而不是看消息。
- Risk: 需要更强的排版控制，否则会显得拥挤。

## Palette

- Background: burnt umber `#181312`
- Surface: carbon brown `#241c1a`
- Accent: copper `#bf7b46`
- Support: sand metal `#efe0cd`

## Layout

- 主卡采用网格化信息切分，像指挥台而不是通知卡。
- 底部四向动作保持存在，但视觉上归入操作面板。
- 右下角永远给出一个“为什么是现在”的小窗。

## Motion

- 执行后铜色条从右向左刷过，像电流完成闭环。
- detail sheet 改为分段折页。
- 稍后动作像把卡片归档进新的槽位。

## SwiftUI Mapping

- `ActionProposalCard` 需要改成 grid-based layout。
- `GestureHintBar` 改成 segmented control 式控制台。
- `DetailSheetView` 需要接近 inspection board。

## Why Choose It

- 这是最像“AI 操作系统控制台”的版本。
- 对技术型观众和产品 demo 很有辨识度。
