# Design · Amber Cab

Version name: `amber-cab`
Status: `DRAFT_OPTION_BATCH_01_2026-04-28`

## Core

- Mood: 夜间出行、城市工具、单手快速处置。
- Best for: 打车、会议、验证码这些强事务动作。
- Risk: 视觉人格很鲜明，不适合想走安静路线时使用。

## Palette

- Background: asphalt `#151311`
- Surface: taxi black `#24201c`
- Accent: cab amber `#d6a43a`
- Support: warm smoke `#f1eadc`

## Layout

- 主卡更像票据和行程单，信息分带很清楚。
- 底部 rail 做成粗胶囊，操作目标更接近 iOS 原生大控件。
- 高置信标签直接贴在卡片边缘，像夜间反光贴。

## Motion

- 左右滑动更快，像在路口做判断。
- 执行动作后底部 rail 会短暂提亮，不依赖 toast 独自表达。
- 空状态像“车已到站”，收尾很利落。

## SwiftUI Mapping

- `ActionProposalCard` 分成票头、证据、执行区三段。
- `ToastView` 改成底部硬胶囊提示带。
- `EmptyStateView` 用大字和反光条语言。

## Why Choose It

- 手机上最容易看清，也最适合真实滑动。
- 如果你想把 NextMove 做成“行动工具”，这套很有说服力。
