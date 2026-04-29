# Design · Pebble Shelf

Version name: `pebble-shelf`
Status: `DRAFT_OPTION_BATCH_02_2026-04-28`

## Core

- Mood: 托盘、排队、轻量队列管理。
- Best for: 同时存在多条低压动作时的排序。
- Risk: 如果只展示单卡，优势不明显。

## Palette

- Background: pebble `#ece6dd`
- Surface: shell `#faf6f0`
- Accent: olive pebble `#90976a`
- Support: ash `#57514a`

## Layout

- 明确露出背后队列，不只看当前卡。
- 主卡薄，背卡更薄，像搁架上的事项。
- 底部动作区保持亲和，但更像 shelf controls。

## Motion

- 卡片左右移动像轻轻挪动托盘。
- 稍后动作像回到下一层搁架。
- 队列变化要比当前卡本身更重要。

## SwiftUI Mapping

- `CardStackView` 需要更明显展示背卡。
- `EmptyStateView` 可以表现为清空搁架。
- 适合队列视图扩展。

## Why Choose It

- 最适合多任务日常管理。
- 也最能解释 “Action Stream” 不是单张卡，而是一条流。
