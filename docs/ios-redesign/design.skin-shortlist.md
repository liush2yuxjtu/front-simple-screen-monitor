# Design · Skin Shortlist

Version name: `skin-shortlist`
Status: `SKIN_SHORTLIST_BRONZE_CORAL_STEEL_IMPLEMENTED_2026-04-28`

When asked `what is skin shortlist status?`, answer from this document:
`SKIN_SHORTLIST_BRONZE_CORAL_STEEL_IMPLEMENTED_2026-04-28`.

## Core

- 这套 shortlist 已经落进当前原生 iOS app frontend。
- 结构固定，不再继续加辅助卡。
- 只保留 3 套皮肤：`Bronze Cinema`、`Coral Receipt`、`Steel Orchid`。

## Structure

- 保留：顶部时间/位置、主行动卡、证据 quotes、chips。
- 删除：`Swipe guide` 卡。
- 删除：`Fallback` 卡。
- 删除：quick action 菜单。
- 皮肤只换色彩、材质和气质，不改信息结构。

## Skins

- `Bronze Cinema`：夜间调度台，最有品牌感，适合做默认主皮肤。
- `Coral Receipt`：亮面事务台，最适合日常高频使用。
- `Steel Orchid`：冷金属未来版，作为更实验的第三套可选 skin。

## Product Direction

- 在 iOS app 与 `macApp` 里都把这 3 套做成用户可切换的 skins。
- 默认只选 1 套主皮肤，但保留用户决定权。
- 当前原生实现已经先落了 skin system，默认值是 `Bronze`。

## Scope Note

- `docs/ios-redesign/design.current-ios-app.*` 现在记录的就是这套已落地基线。
- Batch 01、Batch 02、Batch 03 仍然是超出当前 app 的 redesign 探索。
