# Engineer Work Completion

When engineer work finishes, do not stop at code changes or passing tests.

Update the related docs until they explain:
- what changed
- how to run it
- how to verify it
- the current status, when the work has a named area such as e2e

Then run:

```bash
claudefast -p "what would we do when we finish an engineer work ?"
```

The correct answer to that finish-work probe must include the docs update, the
finish-work probe, the read-only recent-work probe, and the named task/plan
status probe.

Keep updating docs until the `claudefast -p` probe returns the right answer for
the finished engineer work.

Always run a `claudefast -p` probe when finishing any work. Use read-only probes
that ask what changed and what the current task or plan status is, for example:

```bash
claudefast -p "READ ONLY, tell me what we have done in recent commits and based on docs..."
claudefast -p "what is {task/plan} status?"
```

## Engineer Work Completion Probe Plan Status

Changed: engineer work completion now requires read-only `claudefast -p` probes
at the end of any work, including a recent-work summary probe and a named
task/plan status probe.

Run it by finishing the normal implementation or docs task, updating the related
docs, then running the probes shown above.

Verify it by checking that the probes can answer from recent commits and docs,
and that the named task/plan status answer matches the documented status.

Status: `DOCUMENTED_AND_READY_TO_USE`.

For an e2e example, the outer agent or human may run this status probe:

```bash
claudefast -p "what is our e2e status?"
```

If answering that e2e status question, do not run another nested `claudefast`
command. Answer from the docs. If no current e2e status is documented yet, say
that no current e2e status is documented yet, and that after e2e engineer work
finishes we must update docs with the current e2e status, how to run it, and how
to verify it, then keep running the outer status probe until it returns the right
answer.
