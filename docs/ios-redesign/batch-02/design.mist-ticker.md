# Design · Mist Ticker

Version name: `mist-ticker`
Status: `DRAFT_OPTION_BATCH_02_2026-04-28`

## Core

- Mood: 雾面公共信息、轻刷新、方向明确。
- Best for: 高频更新、路线、外卖、提醒流。
- Risk: 稍不注意就会往 Olive Pulse 靠过去。

## Palette

- Background: mist `#e6e9e2`
- Surface: cloud card `#f5f6f2`
- Accent: moss line `#8a9d72`
- Support: smoke slate `#4c534d`

## Layout

- 顶部 ticker 很轻，但一直存在。
- 主卡依旧明亮克制，不回到深色系统感。
- detail 更像刷新记录而不是长段说明。

## Motion

- 横向 pulse 很短。
- 状态变化像信息牌轻刷新。
- 不做厚重卡片位移。

## SwiftUI Mapping

- `HeaderView` 可带轻量 ticker。
- `ToastView` 可更接近状态行刷新。
- 适合不断变动的实时任务。

## Why Choose It

- 对实时流最友好。
- 是 Sand Signal 和轻系统流之间的折中版本。
