# Design · Current iOS App

Version name: `current-ios-app`
Status: `BATCH_00_3_SKINS_IMPLEMENTED_2026-04-28`

## Core

- Mood: 锁屏行动流、影院铜棕、可切换 skin、较厚的 glass surface。
- Best for: 记录当前原生 iOS 原型到底已经实现到了哪一步。
- Risk: 仍是 simulator demo，真实通知和代理链路还没接。

## Layout

- 顶部是锁屏时间、位置、当前 skin 注释和 3 个 skin 切换 pill。
- 中部是 4 张堆叠行动卡，但只有首卡完整展开；后 3 张压成背景队列预览。
- 页面里不再放 `Swipe guide` 卡，不再放 `Fallback` 卡，也不再保留 quick action 菜单。
- 主卡、quotes、次级 chips 和顶部 pill 仍然透明，但已经压厚，不再让后层内容直接透穿。

## Behavior

- 4 张主卡：北京北站、飞书会议、外卖、短信验证码。
- 4 个方向动作：左丢掉、右执行、上依据、下稍后。
- 可见界面不再提供显式备用入口；无障碍 action 仍保留同等操作路径。
- chip 点击只做 demo toast，不做真实跳转或代理执行。
- 录屏 demo 会先轮播 `Bronze`、`Coral`、`Steel`，再进入手势流程。

## Why It Matters

- 这已经不是 future shortlist，而是当前 `swipeV2` iOS app 的真实前端基线。
- `design.skin-shortlist.md` 与这份文档现在已经对齐：同一套结构，三套皮肤。
- Batch 01/02/03 继续是 redesign 探索，不代表当前 app 已经采用它们。
- 产品定义来自 `swipev2/product_design.md` 与 `proposal.md`。
- 演示压力测试来自 `proposal.patch.indexDesign.md` 的 60 秒故事。

## Source Notes

- `swipev2/product_design.md` 定义母题：锁屏不是摘要流，而是 next action 入口。
- `swipev2/product_design.patch.md` 约束当前实现：先做可演示前端，不接真实 agent。
- `swipev2/proposal.md` 补足中文产品叙事：通知先变意图，再变行动。
- `swipev2/proposal.patch.indexDesign.md` 给出 6 个 demo 故事，说明它不是
  “AI 想这么做，你同意吗”，而是“AI 已经替你想好下一步，你只要确认方向”。
