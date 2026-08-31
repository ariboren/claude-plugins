---
name: implement-lite
description: |
  Token-efficient pipeline for executing an implementation plan end to end: worktree, implement,
  verify, DRAFT PR, local platform-aware review, bounded fixup loop, simplify, wrap. Use when
  (1) a plan file exists (SESSION_*.md, *_PLAN.md, docs/plans/*), (2) the user says "implement
  the plan", "run the session", or "implement-lite". Reviews are LOCAL ONLY and never posted to
  the PR/MR. PRs/MRs are always created as drafts.
argument-hint: <plan-path>
allowed-tools: Agent, Bash, Read, Write, Edit, Glob, TodoWrite, AskUserQuestion, EnterWorktree, SendMessage, ListAgents, ToolSearch
---

# implement-lite

Execute one plan → one draft PR, with the smallest number of tokens that still produces
reviewable, standards-compliant work. You are a **working lead**: you own git, the ledger, and
routing. You do not read source files, write code, or form review opinions.

## Non-negotiables

| Never                                                                          | Why                                                                                                                                                      |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Invoke a review/simplify **Skill** from this context                           | Skills load into the _calling_ context. `ios-review-pr`, `review-code`, `simplify` must run **inside a subagent** or their entire output lands in yours. |
| Use `code-review:code-review`, `review-mr`, or `/review`                       | All three are remote-PR tools that **post comments**. `code-review` also refuses to review drafts, so it silently returns no verdict here.               |
| Post review output anywhere                                                    | No `gh pr comment`, `gh pr review`, `glab mr note`, `glab mr approve`. Reviews go to the ledger and chat only.                                           |
| Mark a PR/MR ready                                                             | Always draft. `gh pr ready` / `--ready` only on an explicit user instruction.                                                                            |
| Paste a diff, file contents, or a full agent report into a prompt or into chat | Pass **paths and ranges**. See Token Contract.                                                                                                           |
| Read source files yourself                                                     | Delegate. You may read the plan and the ledger, and run git/test commands.                                                                               |
| Exceed the agent budget                                                        | 8 subagent launches per session. On the 8th, stop and report.                                                                                            |

## Token Contract

1. **Pass by reference.** Subagents get: plan path, ledger path, diff range (`<base>...HEAD`),
   log path. Never the contents. This still holds when resuming an agent via `SendMessage`
   (Phase 5) — point at the ledger section, never paste findings into the message.
2. **Every subagent prompt ends with an output contract.** Verbatim:

   > Output contract: ≤250 words. Sections: `RESULT` (one line), `DETAIL` (bullets, file:line),
   > `BLOCKED` (or "none"). Append your full findings to the ledger at {LEDGER}; keep your
   > reply short. Do not paste code or diffs into your reply.

3. **You distill, you don't relay.** 1–3 lines to the user per phase. Detail lives in the ledger.
4. **Never re-derive what the ledger records.** Read the ledger, not the repo.
5. **Logs go to files.** `… > "$LOG" 2>&1; tail -40 "$LOG"`. Never let a build log into context.
6. **Parallel where independent.** Both Phase 4 reviewers launch in a single message.

## Ledger

Single source of truth, global — **not** inside the repo: `~/.claude/implement-lite/<repo-id>/<slug>.md`.
`<repo-id>` is the `origin` remote URL normalized to a filesystem-safe slug, so it's stable across
every worktree and clone of the same repo: a ledger isn't tied to one checkout and isn't lost when
a worktree is removed after merge. Create in Phase 0:

```bash
REMOTE_URL="$(git remote get-url origin 2>/dev/null)"
REPO_ID="$(printf '%s\n' "${REMOTE_URL:-$(basename "$REPO")}" \
  | sed -E 's#^[a-zA-Z]+://([^@/]+@)?##; s#^([^@:/]+)@([^:/]+)[:/]#\2/#; s#\.git$##; s#[/:]+#-#g')"
LEDGER_DIR="$HOME/.claude/implement-lite/$REPO_ID"
mkdir -p "$LEDGER_DIR"
```

No git-exclude step for the ledger itself — it lives outside the repo entirely.

Verify logs (Phase 2) are the one thing that stays local and worktree-scoped: they're large, and
only useful while this session's still active, so they don't need to survive a worktree teardown.
Keep them at `$REPO/.claude/implement-lite/`, gitignored the same way as before:

```bash
LOG_DIR="$REPO/.claude/implement-lite"
mkdir -p "$LOG_DIR"
EXCL="$(git rev-parse --path-format=absolute --git-common-dir)/info/exclude"
grep -qxF '.claude/implement-lite/' "$EXCL" 2>/dev/null || echo '.claude/implement-lite/' >> "$EXCL"
```

Schema — append-only, terse:

```markdown
# <slug>

plan: <path> base: <branch> branches: <branch1>, <branch2> worktree: <path>
platform: ios|android|generic forge: gh|glab figma: <url>|none pr: <url> (draft)
agents_used: N/8 implementer: <agent-id> (for Phase 5 SendMessage resume)

## Implemented

- <one line per commit>

## Verify

- <cmd> → pass|fail (log: <path>)

## Review — iteration N

- BLOCKING/MAJOR/MINOR | file:line | issue | source: standards|bug-hunt

## Resolved

- <issue> → fixed in <sha>

## Won't fix

- <issue> → reason # reviewers MUST NOT re-raise these

## Open (MINOR, carried to PR body)

- <issue>
```

## Phase 0 — Preflight

One bash block. Derive everything; ask at most one consolidated question.

```bash
git rev-parse --show-toplevel; test -f .git && echo WORKTREE || echo MAIN_REPO
git remote get-url origin 2>/dev/null
git branch -r --list '*/develop' '*/main' '*/master'
ls | head -30
```

Resolve:

| Field    | How                                                                                                                                                                                                                |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| plan     | `$ARGUMENTS`, else glob `SESSION_*.md`, `*_PLAN.md`, `docs/plans/*.md`; if several, ask                                                                                                                            |
| base     | `develop` if `origin/develop` exists, else `main`/`master`. Stacked session N → previous session's branch                                                                                                          |
| platform | `*.xcodeproj`/`*.xcworkspace`/`Package.swift` → **ios** · `settings.gradle*` → **android** · else **generic**                                                                                                      |
| forge    | remote host contains `gitlab` → **glab**; else **gh** (export `GH_HOST=<remote host>` for Enterprise, e.g. `code.espn.com`)                                                                                        |
| ticket   | ticket key in plan path/body/`$ARGUMENTS` (e.g. `ESPNIOS-12345`)                                                                                                                                                   |
| branch   | `<git user first name lowercased>/<TICKET>-<slug>` when a ticket exists, else `<slug>`                                                                                                                             |
| figma    | plan body/`$ARGUMENTS` contains a `figma.com` URL or explicitly references a Figma frame/design/mockup → record the URL (or "referenced, no link"); else **none**. Drives the mandatory Phase 4 fidelity reviewer. |

**Ledger reconciliation (before touching branch/worktree).** Derive `$REPO_ID` and `$LEDGER_DIR` as
in "Ledger" above — this works from any worktree of the repo, since they all share the same
`origin` and therefore the same `$LEDGER_DIR`. Then search for prior work on this ticket before
starting fresh:

```bash
grep -l "$TICKET" "$LEDGER_DIR"/*.md 2>/dev/null
grep -l "$BRANCH" "$LEDGER_DIR"/*.md 2>/dev/null
```

A ledger matches if the ticket key appears in its filename/`plan:` line, or the candidate branch
name appears anywhere in its `branches:` field. On a match:

- Read it. Reuse its `worktree:` and most recent `branches:` entry instead of deriving a new
  branch — `git checkout <branch>` there; don't cut a new one.
- Resume from wherever it left off: "## Review" present with no matching "## Resolved" → re-enter
  Phase 4; no "## Implemented" yet → start at Phase 1 as normal.
- Only append a new entry to `branches:` if you actually had to cut a new branch (stacked session,
  or the rename-on-rejection case in Error handling).

No match → this is new work; continue below.

**Worktree (required unless reconciliation found one).** Read the plan's title/scope only — enough
to name things.

- Already in a worktree (`.git` is a file) → `git checkout -b <branch>` here.
- In the main repo → create one beside the repo, matching the existing layout
  (`<repo-parent>/worktrees/<repo-name>/<short-name>`):

  ```bash
  git fetch origin --quiet
  git worktree add "$WT" -b "$BRANCH" "origin/$BASE"
  ```

  Then switch the session into it with `EnterWorktree` (`path: "$WT"`) so subagents inherit the
  cwd. Never `cd` into the main repo to do branch work; never remove a worktree you didn't create.

Write or update the ledger header (`branches:` starts as a single entry: the branch just resolved
or reused). Create todos: Implement · Verify · Draft PR · Review · Fixup · Simplify · Docs? · Wrap.

## Phase 1 — Implement

Pick one specialist by platform; `general-purpose` if mixed or the specialist is missing (on
"agent not found", retry once with `general-purpose`).

| Platform         | Agent                  |
| ---------------- | ---------------------- |
| iOS / Swift      | `pro:swift-pro`        |
| Android / Kotlin | `pro:mobile-pro`       |
| React Native     | `pro:react-native-pro` |
| TypeScript / web | `pro:typescript-pro`   |
| Backend / API    | `pro:backend-dev`      |
| mixed / unclear  | `general-purpose`      |

```
Agent:
- subagent_type: {SPECIALIST}
- prompt: |
    Implement the plan at {PLAN}. Read it yourself — I have not summarized it for you.

    Follow the plan's steps and file list. Match surrounding code style. Stay in scope:
    do not refactor, rename, or "improve" anything the plan does not ask for.
    If the plan is wrong or ambiguous, implement the most reasonable reading and record the
    assumption in the ledger under "## Implemented" — do not stop to ask.

    Commit in logical units: "{TICKET}: <imperative subject>". Do not push.
    Append what you did (one line per commit) to the ledger at {LEDGER} under "## Implemented".

    {OUTPUT_CONTRACT}
```

Capture the launch result's `agentId` and record it in the ledger header as `implementer: <id>`.
If the tool omits it, `ListAgents` to find it by name before Phase 5. This agent stays addressable
for Phase 5 — resuming it there skips re-deriving codebase context a fresh agent would redo.

## Phase 2 — Verify

Run **only what the plan specifies** (usually targeted unit tests). No full clean builds unless
the plan asks. You run these yourself:

```bash
LOG="$REPO/.claude/implement-lite/verify-$(date +%s).log"
<plan's test command> > "$LOG" 2>&1; echo "exit=$?"; tail -40 "$LOG"
```

Record `cmd → pass|fail (log: path)`. On failure, launch the Phase 1 specialist with the **log
path** and the failing test names — not the log body. Two attempts, then stop and report.
Do not spend a review pass on code that doesn't build or pass its own tests.

Plan specifies no tests → note "no verification specified" in the ledger and continue.

## Phase 3 — Draft PR (always draft)

```bash
git push -u origin "$BRANCH"
```

- **gh:** `gh pr create --draft --base "$BASE" --title "{TICKET}: <subject>" --body "<plan link + WIP>"`
  (prefix `GH_HOST=<host>` for Enterprise). Body is a placeholder at this point — Phase 8 writes
  the real one, per `pr-description`.
- **glab / Android:** delegate to the `create-mr` skill **inside a subagent** — it is already
  draft-first and knows the templates. Tell it: skip its Step 5.5 code review (Phase 4 covers it),
  assign no reviewers, and follow `pr-description` for the body content within the template's
  section structure (what/why, not a commit-by-commit log — Phase 8 will refine it further once
  review has converged).

Assign no reviewers on a draft — they get notified anyway. Record the URL and `draft: true`.

## Phase 4 — Review (LOCAL ONLY)

Two agents — three when `figma:` is not `none` — **one message**, all scoped to
`git diff {BASE}...HEAD`. All read the ledger's "Resolved" and "Won't fix" sections and must not
re-raise settled items.

Shared preamble for both:

```
    Scope: the local diff `git diff {BASE}...HEAD` in this worktree. The code is on disk —
    do not fetch, clone, or check out anything.

    ABSOLUTE: this is a local review. Never run `gh pr comment`, `gh pr review`,
    `glab mr note`, or `glab mr approve`. Never post, publish, or push anything.

    Read {LEDGER} first. Do NOT re-raise anything under "## Resolved" or "## Won't fix".

    Only report an issue you would defend to a senior engineer. Skip: anything a linter,
    formatter, compiler, or CI catches; pre-existing issues; issues on lines this diff did not
    touch; nitpicks; missing test coverage unless the plan required it.

    Label every finding BLOCKING (wrong behavior, security, breaks contract),
    MAJOR (real edge-case bug, missing error handling, unplanned divergence from {PLAN}),
    or MINOR (style, naming, polish — never blocks).

    Append findings to {LEDGER} under "## Review — iteration {N}" with your source tag.
    End with exactly one line: `VERDICT: APPROVED` or `VERDICT: NEEDS_WORK`.
```

**Reviewer A — standards** (source tag `standards`):

| Platform | Instruction                                                                                                                                                                                                 |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ios      | `general-purpose`: "Invoke the `ios-review-pr` skill, but in LOCAL mode: skip its Step 1 entirely (no `gh` fetch, no clone, no temp dir). Apply its checklist and Step 4 summary format to the local diff." |
| android  | `general-purpose`: "Invoke the `review-code` skill on the local diff (its default scope). Use `git diff {BASE}...HEAD`."                                                                                    |
| generic  | `general-purpose`: review against the repo's CLAUDE.md files and the conventions of the surrounding code.                                                                                                   |

**Reviewer B — bug hunter** (`general-purpose`, source tag `bug-hunt`): "Read only the diff. Hunt
logic bugs, unhandled errors, concurrency and lifetime problems, off-by-ones, broken invariants.
Ignore style and conventions entirely — another reviewer owns those."

**Reviewer C — Figma fidelity** (mandatory whenever `figma:` in the ledger header is not `none`;
`general-purpose`, source tag `figma-fidelity`): "Invoke the `figma-fidelity-check` skill against
this local diff (`git diff {BASE}...HEAD`) and the Figma reference {FIGMA_REF} from the ledger
header. Follow its full verification process — resolve every color/spacing/typography token to
its concrete value in the live design-system source, check every visual state variant
(selected/unselected, light/dark, disabled/enabled), and pixel-measure the screenshot where the
structure is ambiguous. Treat this as a fresh check even if a prior phase already claimed the UI
matches Figma. Append findings to {LEDGER} under the same '## Review — iteration {N}' heading with
source tag `figma-fidelity`, then end with the standard VERDICT line." Skip only if the plan and
diff touch no UI/layout code (e.g. a pure backend or data-layer session) despite `figma:` being
set — note that skip and why in the ledger instead of launching the agent.

Merge: any surviving **BLOCKING or MAJOR** from any reviewer, including `figma-fidelity` findings
(a Figma mismatch on a diff-touched screen is at least MAJOR), → `NEEDS_WORK`. Otherwise
**APPROVED**; MINOR items go to "## Open".

> The false-positive rubric is folded into these prompts on purpose. The upstream skill spends one
> extra agent _per candidate issue_ scoring confidence; this gets the same filtering for free.

## Phase 5 — Fixup loop (max 2 iterations)

Only on `NEEDS_WORK`. Resume the **same Phase 1 implementer** via `SendMessage` (id from the
ledger header) instead of launching a fresh subagent — it already has the plan and codebase
loaded, so it isn't re-deriving context a cold-start would pay for again. This also doesn't
count against the 8-agent budget, since no new agent is spawned.

```
SendMessage:
- to: {IMPLEMENTER_AGENT_ID}
- message: |
    Fix the BLOCKING/MAJOR findings under "## Review — iteration {N}" in the ledger at {LEDGER}.
    Read them there — this message does not repeat them.

    Fix each one, or — if a finding is wrong — add it to "## Won't fix" in the ledger with a
    one-line reason instead of changing code. Do not fix MINOR items. Do not refactor.
    Re-run: {VERIFY_CMD}. Commit. Move each fixed item to "## Resolved" with its sha.

    {OUTPUT_CONTRACT}
```

`SendMessage`/`ListAgents` deferred → `ToolSearch: "select:SendMessage,ListAgents"` once, the
first time you need them.

**Unreachable** (id missing from the ledger, session expired, `SendMessage` errors) → fall back
to a fresh Phase 1 launch of {SPECIALIST}, same prompt shape, plan and ledger paths only — never
paste the findings into that prompt either. Note the fallback in the ledger and update
`implementer:` to the new agent id. This fresh launch does count against the 8-agent budget.

Then **delta re-review only**: re-launch Phase 4 scoped to the files the fixup touched
(`git diff --name-only HEAD~<n>..HEAD`), not the whole diff.

```
iteration 1: review → NEEDS_WORK → fixup → delta re-review
iteration 2: NEEDS_WORK → fixup → delta re-review
still NEEDS_WORK → STOP. Summarize the surviving BLOCKING items and AskUserQuestion:
  ship the draft as-is / one more targeted fixup / hand back to me.
```

Never loop past 2. Convergence beats completeness — the PR is a draft and a human reviews it next.

## Phase 6 — Simplify (once, after review converges)

Runs _after_ review so it can't invalidate a verdict. Use the `code-simplifier:code-simplifier`
**agent** (not the `simplify` skill — that would run in your context). Not installed → skip.

```
Agent:
- subagent_type: "code-simplifier:code-simplifier"
- prompt: |
    Simplify only the code changed in this branch (`git diff {BASE}...HEAD`). Preserve behavior
    exactly. No new abstractions, no scope creep, no touching unmodified files. Commit.
    Re-run {VERIFY_CMD} and report pass/fail.
    State explicitly: `BEHAVIOR_NEUTRAL: yes|no`.

    {OUTPUT_CONTRACT}
```

`BEHAVIOR_NEUTRAL: no` or tests fail → one delta re-review of the touched files. Otherwise done.

## Phase 7 — Docs (conditional — usually skipped)

Launch an agent **only if** the plan has an explicit documentation task, or the change adds a
public API / new pattern / new module. Otherwise write "docs: none needed" to the ledger and skip.
An unconditional docs agent is a full-repo scan that usually produces nothing.

## Phase 8 — Wrap

```bash
git push
```

Update the draft PR body. Consult the `pr-description` skill for how to write it — the ledger is
your **source material**, not the shape of the output. Pull from it what a reviewer needs (what
shipped, open MINOR notes worth flagging, plan link) but do not dump the ledger's process detail
into the description: no commit-by-commit narration, no review-iteration counts, no "fixup applied
in response to review" changelog. State what the change does and why, one level above the diff;
mention verification as evidence, not as a log. **Leave it as a draft.**

Report to the user, in this shape:

```
Draft PR: <url>
Shipped: <2-4 lines>
Verify: <cmd> → pass
Review: APPROVED after N iteration(s) · X resolved, Y won't-fix, Z open MINOR
Agents used: N/8
```

Then **stop.** If more sessions exist (`SESSION_{N+1}*`), name them and `AskUserQuestion` whether
to continue — one session per invocation, stacked on this branch. Do not auto-advance.

## Budgets

| Limit                         | Value                                                                          | On breach         |
| ----------------------------- | ------------------------------------------------------------------------------ | ----------------- |
| Subagents per session         | 8 (a Phase 5 `SendMessage` resume doesn't count; a fallback fresh launch does) | Stop, report, ask |
| Review→fixup iterations       | 2                                                                              | Stop, ask         |
| Verify retries                | 2                                                                              | Stop, report      |
| Full-diff reviews             | 1 (later passes are delta-only)                                                | —                 |
| Coordinator source-file reads | 0                                                                              | Delegate          |

## Error handling

- Agent reports `BLOCKED` → `AskUserQuestion` immediately with its one-line reason. Don't guess.
- Specialist agent not found → retry once with `general-purpose`, note it, continue.
- Phase 5 implementer unreachable via `SendMessage` → fresh subagent per Phase 1 (ledger pointer
  only, never the findings text); update `implementer:` in the ledger.
- Branch exists → append `-2`, retry once; append the new name to the ledger's `branches:`.
- Push rejected → `git pull --rebase` once, then ask. Never force-push. Never amend another
  session's commits.
- `gh`/`glab` not authenticated → give the user the exact login command and pause; do not
  work around it.
- Plan and reality disagree (file doesn't exist, API changed) → the implementer records the
  assumption and continues; you surface it in Phase 8.

---

**Start now.** Run Phase 0. Ask for the plan path only if you cannot find it.
