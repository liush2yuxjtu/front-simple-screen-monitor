# Design · Olive Pulse

Version name: `olive-pulse`
Status: `DRAFT_OPTION_BATCH_01_2026-04-28`

## Core

- Mood: 公共信息系统、方向明确、任务先于装饰。
- Best for: 任务型 agent、流程管理、多人协作提醒。
- Risk: 情感温度偏低，需要文案来补。

## Palette

- Background: dark olive `#181a14`
- Surface: signal board `#21241b`
- Accent: dry olive `#a3b36a`
- Support: parchment `#ece7d7`

## Layout

- 顶部信号胶囊更像公共交通 ticker。
- 主卡强调“现在做什么”，次级信息全部退到轨道条。
- detail sheet 用纵向时间线取代普通说明文。

## Motion

- 整体像公共系统的短促刷新，不做柔软玻璃感。
- 执行时出现一条横向 pulse 条。
- 空状态是完整任务清零，而不是简单完成提示。

## SwiftUI Mapping

- `HeaderView` 可以引入 ticker 式动态标签。
- `CardStackView` 要减弱旋转，强化轨道位移。
- `EmptyStateView` 改成清单归零式布局。

## Why Choose It

- 最适合把产品从“demo”推进到“系统工具”叙事。
- 对后续 macOS / iOS 统一设计语言也比较友好。
