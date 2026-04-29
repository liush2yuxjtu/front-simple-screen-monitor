# Design · Moss Agenda

Version name: `moss-agenda`
Status: `DRAFT_OPTION_BATCH_02_2026-04-28`

## Core

- Mood: 日历、agenda、轻协调。
- Best for: 会议、提醒、排程型动作流。
- Risk: 会把产品人格往 calendar app 靠太近。

## Palette

- Background: moss fog `#e5ead9`
- Surface: pale agenda `#f6f8f1`
- Accent: moss `#80955c`
- Support: bark `#495042`

## Layout

- 顶部直接给今日时间段和 agenda 带。
- 顶部 mode header 改成 `YOLO / SAFE / APPROVAL` 三模式。
- 主卡按“现在 / 接下来”排布。
- detail 区更像 agenda 备注。

## Motion

- 行程块像被轻推入正确时间槽。
- 不做 bounce，只做 slotting。
- 稍后动作像改签到下一个时间段。

## SwiftUI Mapping

- `HeaderView` 可整合成 mini agenda。
- `HeaderView` 里适合合并一个轻量 mode selector。
- `CardStackView` 可弱化卡堆感。
- `DetailSheetView` 可更像 note row。

## Why Choose It

- 会议和排程相关故事会非常自然。
- 能让 Action Stream 更像“日程驱动助手”。
