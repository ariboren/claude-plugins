# Subagent model policy

This is the canonical copy. Two other places restate it and must change with it: the `subagent-models` rule and the block messages in the `agent-model-required` hook script. That hook blocks any Agent spawn without `model`, except a fork or a pinned role, and any `escalation` or Fable spawn that is not an escalation.

Why the policy is built this way: `model-policy-rationale.md`, next to this file.

Goal: the least waste. Default to the cheapest, fastest tier that does the job, call the Opus advisor for judgment, and climb a tier only when the task scores higher or an attempt has failed.

Pick the tier per spawn, from the task, not from the role name. A "mechanical" task can hide a judgment and a "review" can be four lines, so score what the agent will actually do.

## Sessions and coordinators

Interactive sessions and coordinators (any session that spawns and drives subagents) run on **Sonnet 5.5 at medium effort**: set `"model": "sonnet"` and the Sonnet effort to `medium` in `~/.claude/settings.json`. They route work, write briefs and read reports; coding, planning and review go to subagents that pin their own tier and effort. A coordinator re-reads its whole growing context on every turn, so cache reads are most of its bill, and Sonnet's cache reads cost half of Opus's.

- **Call the advisor**, if you have the advisor tool (set `"advisorModel": "opus"` in `settings.json`), before committing to an approach on non-trivial work, after two failed attempts at the same step, before declaring multi-step work done, and when a subagent's report conflicts with what you found. It is cheaper than a wrong turn and cheaper than an Opus spawn for a single judgment.
- **Coding live in the session** rather than coordinating: switch with `/effort high`. Switch to Opus with `/model opus` only for a session that is itself the hard reasoning (a long debugging session, a design discussion).

## Score

One point for each that is true:

| Axis | Point when |
|---|---|
| Unchecked | A wrong result reaches nobody who would notice: no test, typecheck, hash compare, reviewer, or owner read-through catches it (labels, judge verdicts, a summary that drops a detail). A review's findings are checked when the fix lands; its misses count here only where a miss is costly (auth, concurrency, payments, data loss). |
| Underspecified | The agent decides what "done" means or picks the approach (writes its own plan, chooses among designs, names the root cause). |
| Interpretive | The agent reads prose or data and interprets it (code review, error analysis, a rubric applied to note content), rather than transforming code with a compiler in the loop. |
| Broad | It must hold invariants across many files or systems at once (cross-cutting change, a full-diff review, a failure that spans systems). |
| Amplified | The output is reused many times downstream: a rubric, a labelled corpus, a judge or production prompt, a plan that gates several milestones. |

| Score | Tier |
|---|---|
| 0 | `sonnet` |
| 1–2 | `opus` (medium) |
| 3+ | `critical` (opus / high); `judge` (opus / xhigh) for measurement |

**Floor:** a task that spends money, touches production, or shapes a measurement never runs below `opus`, whatever it scores. That includes `haiku`.

## Escalations: Opus max, then Fable

A hard task scores 3+ and goes to `critical`; it does not start higher. Above `critical` the ladder is for failures only:

`sonnet` → `opus` medium (`planner`) → `critical` (opus / high) → `critical` with `effort: xhigh` → `escalation` (opus / max) → Fable.

- **`escalation` is Opus at max effort.** On Artificial Analysis's index (v4.3.2) it scores 58 against xhigh's 56 and Fable 5.1's best of 53, at $5.98 per task and about 11 minutes to first token. It is the last routine rung.
- **Fable is off the ladder unless Opus max failed.** Spawn it as `general-purpose` with `model: fable` only after an `escalation` attempt failed, or to continue an eval series Fable already judged, so its scores stay comparable. New series start on `judge`.
- "Failed" means a recorded attempt: a fix that did not fix, a root cause that did not hold, a review the next check proved wrong, or the advisor unable to unstick the step. It does not mean "this looks hard". Skip a rung only when the failure itself or the advisor says the next rung will not help.

The spawn hook blocks an `escalation` spawn or any Fable spawn whose prompt lacks one of:

- `ESCALATION: <earlier attempt — agent or session, its tier — and how it failed>`
- `CONTINUING SERIES: <eval series Fable already judged>` (Fable only)

A repo's own Fable-pinned roles (for example moderation-evaluation's measurement reviewer) are exempt until that repo moves off Fable.

## Haiku lane

A 0-point task goes to `haiku` instead of `sonnet` when the agent only fetches or runs, and the caller can check what comes back.

- **Fetch:** search, file or symbol inventory, read-only git (`log`, `blame`, `diff`, `status`), pulling a value out of a file or log.
- **Run:** execute commands the brief spells out (tests, builds, lint, scripts) and report the result.
- **Commit:** commit the paths the brief lists, with the message the brief gives.

Stay on `sonnet` or above when the agent would explain what code does, choose which command to run, diagnose why a run failed, resolve a conflict, rebase, merge, rewrite history, or push. Those are interpretive or underspecified. A push needs the brief to name it.

Haiku reports have to be checkable. A scout returns `path:line` plus the quoted line for every hit, and lists the searches it ran for any "not found". A runner returns the command, exit code, counts, log path, and failing excerpts. The caller reads whatever it relies on. If a wrong Haiku result would reach nobody who would notice, the task is not 0 points.

**Inline or spawn.** One short command or lookup stays in the calling thread, because a spawn costs more than it saves. Spawn when the output runs past about 100 lines, the search spans more than three files, or several commands run in a row. The goal is to keep that output out of the parent's context.

**Reviewers.** A reviewer scores on its own. The one exception: a reviewer of an `escalation` or Fable artifact runs on `critical` with `effort: xhigh` or higher, since a much weaker reviewer rubber-stamps.

## What costs money

Prices per million tokens (Sonnet 5.5 / Opus 5.5 / Fable 5.1): input $2 / $4 / $10, output $10 / $20 / $50, cache read $0.10 / $0.20 / $0.25 (Sonnet's cache-read price was cut from $0.20 on 2026-10-07).

- Cache reads are most of the bill for agents and sessions with large contexts. Sonnet halves them; a smaller context saves on every tier.
- Effort changes thinking and output tokens and latency, not cache reads. Benchmarks (Artificial Analysis, October 2026), per task: Sonnet medium $0.48 / 127s; Sonnet high $0.88 / 218s; Opus medium $1.34 / 202s; Opus high $1.82 / 268s; Opus xhigh $3.46 / 489s with a 131s first token. Xhigh gets about +2 intelligence-index points over high for twice the cost, which is why it is a per-spawn raise, not a pin (except `judge`, whose output nothing checks).
- Every spawn gets a context pack under 200k tokens: its plan section, the files it edits plus their direct imports, and a digest of the decisions that bind it. Never hand an agent a whole plan, ledger or decisions log. The `subagent-pipelines` skill (`skills/subagent-pipelines/SKILL.md`) covers how to build one.
- A 1–2 point task stays on `opus` medium. Moving it to `sonnet` saves money now that cache reads are cheaper there, but do it only on redo evidence (see Evidence), not to cut cost up front.

## Worked defaults

Starting points; score the actual task when it differs.

| Task | Points | Tier |
|---|---|---|
| Register a script, regenerate fixtures, apply a fully specified table, format fix (`mechanical`) | 0 | `sonnet` |
| Search, file or symbol inventory, read-only git (the reader checks the result) (`scout`) | 0 | `haiku` |
| Run tests, build, lint or a script the brief spells out; report the result (`runner`) | 0 | `haiku` |
| Commit listed paths with a given message (`runner`) | 0 | `haiku` |
| Explain what found code does; pick the command to run; diagnose a failed run | interpretive (+underspecified) | `sonnet` or `opus` by score |
| Summary or distiller with a fixed shape (phase handoff, state-file digest) | 0 | `sonnet` |
| Simplify pass (behavior-neutral, tests + reviewer after it) | 0 | `sonnet` |
| Implementer following a written plan, local decisions left (`implementer`) | 0–1, compiler and tests in the loop | `sonnet` / high |
| Implementer that writes its own plan, one scope; cross-cutting implementer | underspecified (+broad) | `opus` |
| Review of an ordinary diff; fix review of a few commits; plan review | interpretive | `opus` |
| Requirements interviewer; doc update for a landed change | interpretive, underspecified | `opus` |
| Debugger / root-cause on a failing check (the fix is verified by the check that failed) | interpretive, underspecified | `opus` |
| Fresh fixer for a review finding when the author can't be resumed | underspecified | `opus` |
| Harness or eval runner, verification-runner builder (authorized command) | 0–1, floor | `opus` |
| Prompt writer or improver for a skill or agent prompt | unchecked, interpretive | `opus` |
| Planner for one milestone or one batch of waves | underspecified, broad | `opus` |
| Delta check of an approved plan before a branch cut (read-only) | interpretive | `opus` |
| Full review over auth / concurrency / payments; debugger for a failure spanning systems | interpretive, broad, unchecked | `critical` (opus / high) |
| Planner whose plan gates several milestones (avoid: plan one milestone at a time) | underspecified, broad, amplified | `critical` (opus / high) |
| Blind labeller, ground-truth judge, corpus author, rubric writer, production or eval prompt writer | unchecked, interpretive, amplified | `judge` (opus / xhigh) |
| Any of the above after a recorded failure on `critical` at xhigh or `judge` | escalation | `escalation` (opus / max) |
| Any of the above after a recorded failure on `escalation` | escalation | `general-purpose`, `model: fable` |

## Pinned roles: model and effort

Each role in `~/.claude/agents/` (copied from `docs/agents/`) pins a model and an effort. Score the task first, then pick the role at that tier whose effort fits. Spawn a pinned role without `model`. The spawn hook blocks a `model` that differs from the pin, because a call-level `model` replaces the pinned model but keeps the pinned effort.

| Role | Model / effort | Use for |
|---|---|---|
| `scout` | haiku | Search, inventory, read-only git. Returns `path:line` and quotes; never edits. |
| `runner` | haiku | Runs the exact commands in the brief and reports results; commits listed paths. No pushes or history changes. |
| `mechanical` | sonnet / medium | Fully specified, checkable work: register a script, regenerate fixtures, apply a given table, format fix, and git work beyond a plain commit. |
| `implementer` | sonnet / high | Implementation from a plan or clear brief where local decisions remain; a build, tests or a reviewer check it. |
| `planner` | opus / medium | Planning one milestone, delta checks, ordinary diff or plan reviews, root-causing a failing check, driving a workflow. |
| `critical` | opus / high | The rare 3+ point task outside measurement: reviews over auth, concurrency, payments or data loss; cross-system debugging; plans that gate several milestones. |
| `judge` | opus / xhigh | Output that shapes a measurement: labels, blind judging, rubrics, corpora. |
| `escalation` | opus / max | Only after a recorded failure on `critical` at xhigh. Needs an `ESCALATION:` line. |

**Effort overrides.** The Agent call takes an `effort` parameter, and it wins over the frontmatter (the subagent transcript's `perTurnEffort` shows it). This policy authorizes it in these cases only:
- `effort: xhigh` on `critical` when high already failed, or when the task is the hardest in the program and a miss would not be caught later.
- `effort: high` on `planner` for a plan that gates several milestones, when you choose `planner` over `critical`.
- Fable runs at its default effort (medium). Never `xhigh` or `max` on Fable; Opus max already scores higher.

Anything else not covered by a role uses `general-purpose` with `model` set by the score; it runs at the model's default effort from `settings.json` (Sonnet medium, Opus medium). Always pass `model` on non-pinned spawns so the choice is on record. Agent definitions load at session start, so a new or edited role takes effect in the next session. A `fork` ignores both `model` and `effort`: it always runs at the parent's tier and effort.

A plugin agent that pins its own model (e.g. `code-simplifier` at opus) may run one tier above the score; two tiers above → use `general-purpose` with `model` set instead.

Coordinators and main threads hand noisy fetch-and-run work to `scout` and `runner` (see the Haiku lane for the size threshold). Test, build and lint runs go to `runner` with the exact command. Searches across several files go to `scout`.

## How a top-tier spawn spends its tokens

A `critical`, `judge` or `escalation` spawn reasons directly only on the judgment-heavy core that earned the tier. It delegates the rest with `model` set by this policy: file inventories, searches and command runs go to `haiku` (`scout`, `runner`); summaries of material it does not need verbatim and every mechanical edit go to `sonnet`; edits that need judgment go to `opus`. Pass paths and exact decisions, not file contents.

**Where delegation hurts quality, read it yourself.** When the judgment is in the reading, a summary loses it: a judge or labeller reads every input in full and stays blind to anything else; a reviewer reads the diff it is judging; a debugger reads the failing trace; a plan reviewer reads the plan. Delegate reading only for material you will not judge.

## Resume or fresh

An agent's model is fixed at spawn. Before resuming one with `SendMessage`, score the follow-up.

- **Same tier or higher → resume**, unless its context is already past 200k tokens. Then spawn fresh with pointers.
- **Lower tier → fresh agent at the follow-up's tier**, with pointers (plan section, issue, commit shas).
- **Context wins** (resume despite a lower score) only when the follow-up needs reasoning that lives in that agent and not in files: fixing a review finding or a failing test in code it wrote, answering a question about its own plan.
- Never carry one agent across phases of a plan. Spawn fresh per phase.

## Tuning the thresholds

When a task has to be redone, note `redo: <why>` next to that work, with the agent's model and description. A redo on a `haiku` spawn moves that task type up to `sonnet`. A redo on a `sonnet` or `opus` spawn is the signal to raise a threshold. Several runs with no redo on `opus` spawns that score 1 is the signal to try `sonnet` there. Every `escalation` or Fable spawn is a redo of the rung below it: if one task type escalates repeatedly, raise its starting rung. If Fable never succeeds where `escalation` failed, drop Fable from the ladder.
