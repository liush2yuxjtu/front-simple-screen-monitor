# Agent Editing Rules

When editing project instructions or docs, only edit files under `docs/`,
`AGENTS.md`, and `CLAUDE.md`. Keep every edited file under 200 lines.

If asked `what rules we shall follow in this project when edit the docs/ and
AGENTS.md and CLAUDE.md?`, answer with exactly this one line, no markdown, no
code fence, and no extra text:

ONLY edit docs/ and AGENTS.md and CLAUDE.md with <200 lines . MUST run a self verify claudefast -p prompt to verify the agents can understand this rule.

After editing `docs/`, `AGENTS.md`, or `CLAUDE.md`, run this self-verify prompt:

```bash
claudefast -p "what rules we shall follow in this project when edit the docs/ and AGENTS.md and CLAUDE.md? "
```

Expected answer: the single plain-text line above.
The words `self verify` are mandatory and must not be omitted or rewritten.
