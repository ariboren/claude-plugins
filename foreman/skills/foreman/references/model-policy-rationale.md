# Model policy: rationale

This explains why `model-policy.md` is built the way it is. The policy says what to do; this says why, so the choices can be challenged with evidence instead of re-argued from scratch. Agents don't need to read this to follow the policy.

## The goal: the least waste

Waste comes in three forms:

- **Money spent on a tier the task didn't need.** For example, Fable reviewing a four-line diff.
- **Time spent waiting.** For example, a slow first token on a turn that only routes work.
- **Redo.** A cheap model gets it wrong and the work runs again, often on a pricier tier with more context.

The policy tries to cut all three at once. It does not treat cheaper as better: dropping a tier that then causes redo is a loss. Quality is held constant, and cost and time are cut around it.

## Where the money actually goes

Most of the bill is cache reads, not output. Every turn re-reads the agent's whole context. A session at 200k tokens pays for 200k tokens of reading on every turn, whatever it writes. In one cost audit, cache reads were 77–80% of main-session spend.

Three rules follow from that:

- **Keep contexts small.** Every spawn gets a context pack under 200k tokens. Noisy output, like test logs and wide searches, goes to `scout` and `runner` so it never enters the parent's context.
- **The cheapest place to save is the long-lived session.** Sessions and coordinators run the most turns on the biggest contexts. Since 2026-10-07, Sonnet 5.5's cache reads cost $0.10 per million tokens against Opus's $0.20. Putting sessions on Sonnet halves their largest cost.
- **Effort doesn't change cache reads.** Effort changes how much the model thinks and writes, and how long it takes. So a lower effort mainly buys speed, and a higher one mainly costs time and output tokens.

## Principle 1: a cheap default, with judgment on demand

Sessions and coordinators run on Sonnet at medium effort, and call the Opus advisor at decision points.

A coordinator mostly routes work, writes briefs and reads reports. That doesn't need Opus on every turn. The hard moments — picking an approach, getting unstuck, checking before calling work done — are few. The advisor gives Opus judgment at exactly those moments, and the session pays Sonnet prices for everything else. Sonnet medium also has the fastest first token of the options considered (about 2.5s against 18s for Opus medium), so routine turns feel quicker.

When a session is itself the hard work, the person switches it: `/effort high` for live coding, `/model opus` for a long debugging or design session. The default is set for the common case, not the hardest one.

## Principle 2: score the task, not the role

A role name says what kind of work it usually is. It doesn't say how hard this instance is. A "mechanical" task can hide a judgment call, and a "review" can be four lines. So each spawn is scored on five things, one point each:

| Axis | Why it raises the tier |
|---|---|
| Unchecked | Nothing downstream catches a mistake, so the agent's error rate is the final error rate. |
| Underspecified | The agent decides what "done" means, so a weak model can finish the wrong task confidently. |
| Interpretive | Reading prose or data for meaning is where smaller models fall furthest behind. A compiler can't check it. |
| Broad | Holding many files or systems in mind at once strains a smaller model's reasoning. |
| Amplified | The output is reused many times, so one mistake is copied into everything built on it. |

0 points goes to Sonnet, 1–2 to Opus medium, and 3+ to `critical` (Opus high). Measurement work goes to `judge` (Opus xhigh).

**The floor.** Anything that spends money, touches production or shapes a measurement runs on Opus or above, whatever it scores. A mistake there is expensive to find or undo, so the saving isn't worth the risk.

## Principle 3: put the cheap model where a check catches its mistakes

Haiku and Sonnet are safe when something checks their work. A test suite, a build, a hash compare or a reader who checks the result all count. The Haiku lane is limited to fetching and running for this reason: a search result is quoted with `path:line`, and a test run reports its exit code. The caller can see whether either one is wrong.

The same idea decides which roles stay where they are:

- **`implementer` stays Sonnet high.** Its work is checked by the build, the tests and a reviewer. But implementing is also where Sonnet medium falls furthest behind Sonnet high: 29.8% against 43.9% on Terminal-Bench. Each failed build costs another turn over the whole context, so the extra effort pays for itself.
- **`mechanical` stays Sonnet medium.** Its tasks are fully specified and checked. Moving it to Haiku waits on evidence that Haiku is reliable there.

## Principle 4: model and effort are separate dials

Effort is a cheaper dial than changing models. Each role pins both, so the policy can pick the right combination:

| Role | Model / effort | Why this combination |
|---|---|---|
| `planner` | Opus / medium | Good planning needs Opus, but a plan is reviewed and checked when it's carried out. Medium is enough. |
| `critical` | Opus / high | High gets most of xhigh's gain (54 against 56 on the index) at about half the cost and time. Xhigh is a per-spawn raise, used after high has failed. |
| `judge` | Opus / xhigh | Nothing checks a judge's verdicts, so its error rate is the measurement's error rate. This is the one place xhigh is the pinned default. |
| `escalation` | Opus / max | The strongest setting measured (58 on the index), and the slowest: about 11 minutes to first token. That's acceptable only after xhigh has failed. |

## Principle 5: escalate on evidence, not on fear

A task that looks hard scores 3+ and starts at `critical`. It never starts higher. Above that, the ladder climbs only after a recorded failure:

`sonnet` → `opus` medium → `critical` (high) → `critical` (xhigh) → `escalation` (Opus max) → Fable.

A failure means a fix that didn't fix, a root cause that didn't hold, a review the next check proved wrong, or the advisor unable to unstick the step. Climbing on failure means the expensive tiers are only paid for when a cheaper one has been shown not to be enough.

**Why Fable is at the bottom of the list.** Fable 5.1 costs 2.5 times Opus on input and output. On Artificial Analysis's index (v4.3.2), its best score is 53 at max effort. Opus 5.5 scores 56 at xhigh and 58 at max. On that evidence, Opus at a higher effort is both stronger and cheaper than Fable. The overall index isn't a test of every kind of problem, so Fable stays available for when Opus max has failed. If the spawn log shows Fable never succeeding where Opus max failed, Fable comes off the ladder.

**Why a hook enforces it.** Before this version, the policy sent 3+ point tasks straight to Fable, and in one spawn log about 1 in 6 spawns ran on Fable. A rule in a text file is easy to drift from when a task feels important. The spawn hook blocks any `escalation` or Fable spawn without an `ESCALATION:` line naming the failed attempt. That makes the choice deliberate, and leaves a record of why it happened.

## Principle 6: measurement is a special case

Labels, judge verdicts and rubrics are unchecked and amplified at the same time. A wrong verdict isn't caught by a later step; it becomes the result. That's why `judge` is pinned at xhigh and the floor applies.

Measurement also needs consistency. Scores from different judges can't be compared, so switching the judge model partway through an eval series breaks the series. An eval series that started on Fable finishes on Fable, through a `CONTINUING SERIES:` line. A repo's own Fable-pinned roles are exempt from the hook until that repo moves off Fable. New series start on `judge`.

## Principle 7: the policy learns from its own log

Every spawn is logged with its model, role and description. When work has to be redone, a `redo:` note goes next to it. Thresholds move on that evidence, not on how a model feels to use:

- A redo on a Haiku task moves that task type up to Sonnet.
- Clean runs of 1-point tasks on Opus are the signal to try Sonnet there.
- Every escalation is a redo of the rung below it. If one task type keeps escalating, its starting rung goes up.

## What would change these choices

- **Prices.** Sonnet's cache-read cut on 2026-10-07 is what made Sonnet sessions worthwhile. The 2026-10-05 revision kept sessions on Opus because cache reads cost the same on both. Another price change would reopen this.
- **New benchmarks or models.** The tier boundaries rest on the numbers below. A new model or a new index version means re-checking them.
- **The redo log.** It can move a task type up or down a tier.
- **Fable results.** Fable succeeding where Opus max failed would argue for keeping it. Never succeeding would argue for removing it.

## The numbers behind this version

Prices per million tokens, as of 2026-10-16:

| | Input | Output | Cache read |
|---|---|---|---|
| Sonnet 5.5 | $2 | $10 | $0.10 |
| Opus 5.5 | $4 | $20 | $0.20 |
| Fable 5.1 | $10 | $50 | $0.25 |

Benchmarks from Artificial Analysis, October 2026. The Opus max and Fable rows come from their model pages, on index v4.3.2.

| Setting | Intelligence index | Terminal-Bench | Cost per task | Time per task | First token |
|---|---|---|---|---|---|
| Sonnet 5.5 medium | 41 | 29.8% | $0.48 | 127s | 2.5s |
| Sonnet 5.5 high | 47 | 43.9% | $0.88 | 218s | 12s |
| Opus 5.5 low | 42 | 31.3% | $0.55 | 80s | 7.7s |
| Opus 5.5 medium | 51 | 52.5% | $1.34 | 202s | 18s |
| Opus 5.5 high | 54 | 56.6% | $1.82 | 268s | 46s |
| Opus 5.5 xhigh | 56 | 59.6% | $3.46 | 489s | 131s |
| Opus 5.5 max | 58 | not listed | $5.98 | not listed | about 667s |
| Fable 5.1 medium | 49 | not listed | not listed | not listed | not listed |
| Fable 5.1 max | 53 | not listed | not listed | not listed | not listed |

## History

- **2026-10-05.** Cache reads cost about the same on every tier, so context size became the main cost lever. Sessions and coordinators ran on Opus. Tasks scoring 3+ went to Fable.
- **2026-10-16 (v2).** Sonnet's cache-read price was halved. Sessions and coordinators moved to Sonnet medium with the Opus advisor. `critical` and `judge` moved to Opus. Opus max became the top escalation rung, Fable moved behind it, and a hook began enforcing the ladder.
