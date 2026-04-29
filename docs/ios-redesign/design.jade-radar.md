# Design · Jade Radar

Version name: `jade-radar`
Status: `DRAFT_OPTION_BATCH_01_2026-04-28`

## Core

- Mood: 导航系统、路径判断、实时校正。
- Best for: 接人、路线、到达前提醒这类位置驱动任务。
- Risk: 如果产品故事偏社交，这套会显得过于“系统化”。

## Palette

- Background: deep moss `#141914`
- Surface: forest glass `#1f2720`
- Accent: jade `#8fbf6c`
- Support: fog `#e8eadf`

## Layout

- 顶部不强调“锁屏美感”，强调“当前坐标系”。
- 主卡下面直接给三格状态条：置信度、倒计时、干预级别。
- detail sheet 更像路线分镜，而不是普通 sheet。

## Motion

- 上滑 detail 时，卡片边框变成扫描线。
- 下滑稍后时，卡片像被送回队尾的传送带。
- 整体动效轻，不走 flashy 路线。

## SwiftUI Mapping

- `HeaderView` 新增状态带和雷达式点阵分隔。
- `CardStackView` 背卡改成更窄的轨道卡影。
- `DetailSheetView` 用 step route，而不是普通列表块。

## Why Choose It

- 非常贴合“通知流变行动流”的产品本质。
- 配色克制，容易长期迭代成系统产品。
