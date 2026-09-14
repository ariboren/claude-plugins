# Subagent model policy

Canonical copy, linked globally as `~/.claude/model-policy.md` so sessions outside any plugin read
the same file. `~/.claude/hooks/agent-model-required.sh` blocks any Agent spawn without `model`.
implement-lite inlines a summary; keep it in sync.

Pick the tier per spawn, from the task, not from the role name. A "mechanical" task can hide a
judgment and a "review" can be four lines, so score what the agent will actually do.

## Score

One point for each that is true:

| Axis           | Point when                                                                                                                                                                                                                                                                                                                            |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Unchecked      | A wrong result reaches nobody who would notice: no test, typecheck, hash compare, reviewer, or owner read-through catches it (labels, judge verdicts, a summary that drops a detail). A review's findings are checked when the fix lands; its misses count here only where a miss is costly (auth, concurrency, payments, data loss). |
| Underspecified | The agent decides what "done" means or picks the approach (writes its own plan, chooses among designs, names the root cause).                                                                                                                                                                                                         |
| Interpretive   | The agent reads prose or data and interprets it (code review, error analysis, a rubric applied to note content), rather than transforming code with a compiler in the loop.                                                                                                                                                           |
| Broad          | It must hold invariants across many files or systems at once (cross-cutting change, a full-diff review, a failure that spans systems).                                                                                                                                                                                                |
| Amplified      | The output is reused many times downstream: a rubric, a labelled corpus, a judge or production prompt, a plan that gates several waves of agents.                                                                                                                                                                                     |

| Score | Tier                                 |
| ----- | ------------------------------------ |
| 0     | `sonnet`                             |
| 1–2   | `opus`                               |
| 3+    | `fable` (the strongest tier offered) |

**Floor:** a task that spends money, touches production, or shapes a measurement never runs below
`opus`, whatever it scores. Never `haiku`.

**Reviewer of a fable artifact is fable.** A reviewer below its author's tier rubber-stamps.
Otherwise a reviewer scores on its own.

Difficulty is the Broad axis, kept separate from nature: a large mechanical change is still checked,
but a weak model thrashes on it.

## Worked defaults

Starting points; score the actual task when it differs.

| Task                                                                                               | Points                             | Tier     |
| -------------------------------------------------------------------------------------------------- | ---------------------------------- | -------- |
| Commit, register a script, regenerate fixtures, apply a fully specified table, format fix          | 0                                  | `sonnet` |
| Explore / search / file inventory (the reader checks the result)                                   | 0                                  | `sonnet` |
| Summary or distiller with a fixed shape (phase handoff, state-file digest)                         | 0                                  | `sonnet` |
| Simplify pass (behavior-neutral, tests + reviewer after it)                                        | 0                                  | `sonnet` |
| Implementer that writes its own plan, one scope; cross-cutting implementer                         | underspecified (+broad)            | `opus`   |
| Review of an ordinary diff; fix review of a few commits; plan review                               | interpretive                       | `opus`   |
| Requirements interviewer; doc update for a landed change                                           | interpretive, underspecified       | `opus`   |
| Debugger / root-cause on a failing check (the fix is verified by the check that failed)            | interpretive, underspecified       | `opus`   |
| Fresh fixer for a review finding when the author can't be resumed                                  | underspecified                     | `opus`   |
| Harness or eval runner, verification-runner builder (authorized command)                           | 0–1, floor                         | `opus`   |
| Prompt writer or improver for a skill or agent prompt                                              | unchecked, interpretive            | `opus`   |
| Full review over auth / concurrency / payments; debugger for a failure spanning systems            | interpretive, broad, unchecked     | `fable`  |
| Planner for a multi-wave effort (single-session plan: drop amplified → `opus`)                     | underspecified, broad, amplified   | `fable`  |
| Reviewer of a fable-authored plan or diff                                                          | rule above                         | `fable`  |
| Blind labeller, ground-truth judge, corpus author, rubric writer, production or eval prompt writer | unchecked, interpretive, amplified | `fable`  |

Pinned agent definitions in `~/.claude/agents/` enforce the two tiers that never depend on the
instance: `mechanical` (sonnet) and `judge` (fable). Use them when they fit. Not installed → use
`general-purpose` with the tier set explicitly. Everything else sets `model` on the Agent call.
Always pass `model` explicitly, even when it matches your own tier, so the choice is on record.

A plugin agent that pins its own model (e.g. `code-simplifier` at opus) may run one tier above the
score; two tiers above → use `general-purpose` with `model` set instead.

## How a Fable agent spends its tokens

A Fable spawn, and a coordinator session running on Fable (foreman, implement-lite, plan-loop
leads), is the coordinator of its own task. It reasons directly only on the judgment-heavy core
that earned the tier, and delegates the rest with `model` set by this policy: file inventories,
searches, summaries of material it does not need verbatim, and every mechanical edit (applying a
decided table, version bumps, formatting) go to `sonnet`; edits that need judgment go to `opus`.
Pass paths and exact decisions, not file contents.

**Where delegation hurts quality, read it yourself.** When the judgment is in the reading, a
summary loses it: a judge or labeller reads every input in full and stays blind to anything else;
a reviewer reads the diff it is judging; a debugger reads the failing trace; a plan reviewer reads
the plan. Delegate reading only for material you will not judge (where a symbol lives, what a
plugin's versions are, which files mention X). Spawn-prompt clause, for any fable spawn:

> You are on the strongest tier. Delegate searches, summaries and mechanical edits to `sonnet`
> subagents (paths, not contents); reason yourself on the judgment this task exists for, and read
> in full anything you are judging.

## Resume or fresh

An agent's model is fixed at spawn. Before resuming one with `SendMessage`, score the follow-up.

- **Same tier or higher → resume.** Its context is free.
- **Lower tier → fresh agent at the follow-up's tier**, with pointers (state file section, issue,
  shas). A one-line commit does not need a Fable agent's context.
- **Context wins** (resume despite a lower score) only when the follow-up needs reasoning that lives
  in that agent and not in files: fixing a review finding or a failing test in code it wrote,
  answering a question about its own plan. Work fully described by files never qualifies.

## Evidence

Record the tier on every spawn (foreman: `state.md` wave table Model column; implement-lite: ledger
`models:` line). When a task has to be redone, note `redo: <why>` on that row. After a few runs, a
redo on a `sonnet` or `opus` row is the signal to move a threshold; none means they hold.
