# Design · Linen Ledger

Version name: `linen-ledger`
Status: `DRAFT_OPTION_BATCH_02_2026-04-28`

## Core

- Mood: 晨间工作台账、清醒、克制。
- Best for: 会议、邮件、待办这类工作日整理动作。
- Risk: 不够戏剧化，更依赖真实产品语境。

## Palette

- Background: linen `#ede4d7`
- Surface: paper `#faf5ee`
- Accent: moss ink `#8a9b64`
- Support: walnut `#4a4037`

## Layout

- 主卡像一张日报卡，而不是通知。
- 次级证据改成台账行，不做悬浮解释泡。
- 底部动作区更像办公工具栏。

## Motion

- 只做轻微推移和 opacity 变化。
- 执行后状态行短暂加深。
- 稍后像把条目移到下午栏。

## SwiftUI Mapping

- `ActionProposalCard` 可更像 list row + summary card。
- `GestureHintBar` 可与 toolbar 融合。
- `DetailSheetView` 改成内嵌展开行。

## Why Choose It

- 最像真实工作日会长期使用的版本。
- 对桌面和 iPad 扩展也比较自然。
