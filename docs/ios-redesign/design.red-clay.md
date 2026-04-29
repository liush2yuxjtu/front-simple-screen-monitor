# Design · Red Clay

Version name: `red-clay`
Status: `DRAFT_OPTION_BATCH_01_2026-04-28`

## Core

- Mood: warm pressure, premium urgency, city-night confidence.
- Best for: 北京北站、外卖、会议这类“现在就决定”的场景。
- Risk: 情绪张力最强，做不好会显得过热。

## Palette

- Background: smoked plum-brown `#231816`
- Surface: iron brown `#342522`
- Accent: clay red `#c96b4b`
- Support: oat `#f4e5d3`

## Layout

- 顶部时间保持巨大，但下面的信号胶囊更短更硬。
- 主卡像厚陶片，引用区和行动区之间有明确压痕。
- 底部动作栏做成一整条横向决策台，不再像四个松散按钮。

## Motion

- 滑动时卡片像重物被推走，阻尼偏大。
- 执行用短促暖色闪面，不做霓虹发光。
- detail sheet 从底部像抽屉一样推出。

## SwiftUI Mapping

- `LockWallpaperView` 改成暖棕渐变和低位余晖。
- `ActionProposalCard` 用厚边界、强内阴影、分段布局。
- `GestureHintBar` 合并为单一 dock rail。

## Why Choose It

- 最容易做出“这不是消息，这是命令前室”的气质。
- 对 demo 叙事最有冲击力，尤其适合投资人和现场演示。
