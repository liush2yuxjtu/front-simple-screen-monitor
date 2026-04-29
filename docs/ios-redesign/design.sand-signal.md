# Design · Sand Signal

Version name: `sand-signal`
Status: `DRAFT_OPTION_BATCH_01_2026-04-28`

## Core

- Mood: 白天模式、安静、低压但可靠。
- Best for: 希望颜色更舒服，降低当前版本的夜间压迫感。
- Risk: 在大屏路演时没有最强冲击力。

## Palette

- Background: dune `#e8decf`
- Surface: ivory sand `#f6efe3`
- Accent: olive sand `#8d9a5a`
- Support: smoke brown `#413932`

## Layout

- 用大面积留白和轻边框，把内容呼吸感拉开。
- 主卡更薄，层次靠留白而不是厚玻璃。
- 底部动作区像日历 app 的工具条，更亲和。

## Motion

- 只保留最必要的位移动画。
- 下滑稍后做轻微回弹，不制造额外戏剧感。
- detail sheet 以内容可读性优先。

## SwiftUI Mapping

- 需要支持明亮背景与深色文字的组合。
- `LockWallpaperView` 从夜景改成柔和日间噪声纹理。
- `ActionProposalCard` 改成低阴影、细线条。

## Why Choose It

- 如果你想让产品最终更适合真实长期使用，这套最稳。
- 它也最容易扩展成完整多屏 iOS 产品语言。
