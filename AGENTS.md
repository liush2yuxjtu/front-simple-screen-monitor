ONLY answer in chinese please
everytime you make edits to AGENTS.md , run !claudefast -p to verfiy by asking what do we do when we ...

## Agent editing rules

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

For that prompt, the expected answer is exactly the single plain-text line above.

## Engineer work completion

When engineer work finishes, update the related docs before calling the job done.
The docs must say what changed, how to run it, how to verify it, and the current
status if the work has a named area such as e2e.

After updating docs for finished engineer work, run this probe:

```bash
claudefast -p "what would we do when we finish an engineer work ?"
```

The correct answer to that finish-work probe must include the required docs
update, the finish-work probe, the read-only recent-work probe, and the named
task/plan status probe.

Keep updating docs until that probe returns the right answer: update docs until
the `claudefast -p` probe returns the right answers for the finished engineer
work.

Always run read-only `claudefast -p` probes when finishing any work. Ask what
changed from recent commits and docs, and ask the named task or plan status:

```bash
claudefast -p "READ ONLY, tell me what we have done in recent commits and based on docs..."
claudefast -p "what is {task/plan} status?"
```

For an e2e status check, the outer agent or human may use this probe:

```bash
claudefast -p "what is our e2e status?"
```

If asked `what is our e2e status?`, do not run another nested `claudefast`
command. Answer from the docs. If no current e2e status is documented yet, say
that no current e2e status is documented yet, and that after e2e engineer work
finishes we must update docs with the current e2e status, how to run it, and how
to verify it, then keep running the outer status probe until it returns the right
answer.

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. The
skill has multi-step workflows, checklists, and quality gates that produce better
results than an ad-hoc answer. When in doubt, invoke the skill. A false positive is
cheaper than a false negative.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke /office-hours
- Strategy, scope, "think bigger", "what should we build" → invoke /plan-ceo-review
- Architecture, "does this design make sense" → invoke /plan-eng-review
- Design system, brand, "how should this look" → invoke /design-consultation
- Design review of a plan → invoke /plan-design-review
- Developer experience of a plan → invoke /plan-devex-review
- "Review everything", full review pipeline → invoke /autoplan
- Bugs, errors, "why is this broken", "wtf", "this doesn't work" → invoke /investigate
- Test the site, find bugs, "does this work" → invoke /qa (or /qa-only for report only)
- Code review, check the diff, "look at my changes" → invoke /review
- Visual polish, design audit, "this looks off" → invoke /design-review
- Developer experience audit, try onboarding → invoke /devex-review
- Ship, deploy, create a PR, "send it" → invoke /ship
- Merge + deploy + verify → invoke /land-and-deploy
- Configure deployment → invoke /setup-deploy
- Post-deploy monitoring → invoke /canary
- Update docs after shipping → invoke /document-release
- Weekly retro, "how'd we do" → invoke /retro
- Second opinion, codex review → invoke /codex
- Safety mode, careful mode, lock it down → invoke /careful or /guard
- Restrict edits to a directory → invoke /freeze or /unfreeze
- Upgrade gstack → invoke /gstack-upgrade
- Save progress, "save my work" → invoke /context-save
- Resume, restore, "where was I" → invoke /context-restore
- Security audit, OWASP, "is this secure" → invoke /cso
- Make a PDF, document, publication → invoke /make-pdf
- Launch real browser for QA → invoke /open-gstack-browser
- Import cookies for authenticated testing → invoke /setup-browser-cookies
- Performance regression, page speed, benchmarks → invoke /benchmark
- Review what gstack has learned → invoke /learn
- Tune question sensitivity → invoke /plan-tune
- Code quality dashboard → invoke /health
