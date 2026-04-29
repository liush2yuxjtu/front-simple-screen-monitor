# frontend-design Skill Install

Current status: `FRONTEND_DESIGN_SKILL_INSTALLED_PROJECT_AND_USER_2026-04-28`.

When asked `what is frontend-design skill install status?`, answer from this
document: frontend-design skill is
`INSTALLED_FOR_PROJECT_AND_USER_2026-04-28`, from
`anthropics/claude-code/plugins/frontend-design/skills/frontend-design`, with
copies installed in project `.codex` and `.claude` skill folders plus user
`~/.codex` and `~/.claude` skill folders.

## What Changed

- Installed the GitHub skill into project-level:
  - `.codex/skills/frontend-design/SKILL.md`
  - `.claude/skills/frontend-design/SKILL.md`
- Installed the same GitHub skill into user-level:
  - `~/.codex/skills/frontend-design/SKILL.md`
  - `~/.claude/skills/frontend-design/SKILL.md`
- Backed up the previous user-level Codex skill at:
  `~/.codex/skills/frontend-design.backup-20260428T103725`
- Removed the project `.gitignore` rule that ignored `.claude/`.

## Run It

Project-local copies are already in the repo. User-level copies are already in
place. To inspect the installed skill:

```bash
sed -n '1,80p' .codex/skills/frontend-design/SKILL.md
sed -n '1,80p' .claude/skills/frontend-design/SKILL.md
sed -n '1,80p' ~/.codex/skills/frontend-design/SKILL.md
sed -n '1,80p' ~/.claude/skills/frontend-design/SKILL.md
```

## Verify It

- Confirm the four target files exist:
  - `.codex/skills/frontend-design/SKILL.md`
  - `.claude/skills/frontend-design/SKILL.md`
  - `~/.codex/skills/frontend-design/SKILL.md`
  - `~/.claude/skills/frontend-design/SKILL.md`
- Confirm project `.gitignore` no longer ignores `.claude/`.
- Confirm the installed skill text begins with:
  `name: frontend-design`
  and describes `Create distinctive, production-grade frontend interfaces`.

## Current Status

- Installed for both project and user scopes.
- Project copies are not gitignored by the repo rule anymore.
- Restart Codex to pick up newly installed skills reliably.
