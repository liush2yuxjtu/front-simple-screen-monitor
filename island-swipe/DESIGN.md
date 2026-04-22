# island-swipe Design Spec

## Concept
High-tech Dynamic Island screen activity monitor. Clean terminal/system-monitor aesthetic. No 中二 metaphors. Swipe-based consent interaction.

## Visual Direction
**Terminal Noir** — dark, precise, functional. Like a futuristic OS system monitor or an AI assistant's activity log.

## Color Palette
| Token | Hex | Use |
|-------|-----|-----|
| `--bg` | `#04080f` | Main background |
| `--surface` | `#0a1520` | Phone/screen surface |
| `--cyan` | `#00e5ff` | Primary accent, "ALLOW" |
| `--lime` | `#76ff03` | Approval / "pass" |
| `--red` | `#ff1744` | Deny / "block" |
| `--text` | `#e0f7fa` | Primary text |
| `--muted` | `#4a6a7a` | Secondary text |
| `--border` | `#1a3a4a` | Subtle borders |

## Typography
- **UI**: `JetBrains Mono` (Google Fonts) — monospace, tech feel
- **Chinese**: `Noto Sans SC` — clean, modern
- **Display numbers**: tabular nums, monospace

## Layout
- Full-screen phone mockup (iPhone frame)
- Dynamic Island pill at top
- Below: stats panel (ALLOWED / BLOCKED / TOTAL)
- Swipe hint arrows inside expanded island

## Interactions
- **Left swipe** → BLOCK (red flash, block icon)
- **Right swipe** → ALLOW (green flash, check icon)
- **Swipe threshold**: 90px
- **Auto-expand**: 1.2s after notification appears
- **Haptic**: vibrate on swipe complete

## Metadata
- Title: `灵动岛 · Activity Monitor`
- Sub: `Swipe to decide · Left = BLOCK · Right = ALLOW`
- Tally labels: `ALLOWED` / `BLOCKED` / `TOTAL`

## Metaphors Stripped
- ❌ 焚毁 / 盖印 / 御批 / 奏疏 / 御史
- ✅ ALLOW / BLOCK / MONITOR / APPROVE / DENY
