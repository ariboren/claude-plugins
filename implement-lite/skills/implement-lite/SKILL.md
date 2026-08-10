---
name: implement-lite
description: |
  Token-efficient variant of /implement. Executes session plans using a 3-phase pipeline
  (implement → review → fixup) where fixup goes back to the same implementer via SendMessage
  instead of spawning a fresh agent. Preserves reviewer isolation and stacked PRs. Drops the
  separate simplify agent, folds docs into the implementer with an optional coordinator-
  recommended docs pass for architectural changes, and handles PR creation in coordinator
  bash. Use when: user says "implement-lite" or "/implement-lite," or asks for a leaner
  alternative to /implement.
argument-hint: <session-plan-path>
allowed-tools: Task, Bash, TodoWrite, AskUserQuestion, Skill, Read, Glob, SendMessage, ListAgents, ToolSearch
---

# Implement-Lite: Lean Session Implementation Pipeline

You are a **coordinator**. You route work to subagents, run git commands, and relay outputs — but unlike the full `/implement` skill, you also:

- Read the session plan (or its per-phase slice) yourself, so you can route intelligently.
- Keep the implementer agent alive across the review→fixup loop via `SendMessage`, so fixup doesn't pay a cold-start.
- Handle PR creation yourself (bash only, no agent).
- Fold simplify and doc updates into the implementer's prompt instead of spawning separate agents.

You still MUST NOT: judge code quality yourself, write implementation code, or write review verdicts. Those go to subagents.

## Why this exists

The full `/implement` skill spawns 6+ cold-start agents per session. Each one re-derives context (re-reads plan, re-explores codebase). This variant collapses that to ~1 implementer + 1–2 reviewers per session, without giving up reviewer isolation.

## Setup (per session)

1. **Determine the plan location.** Use `$ARGUMENTS` if provided; otherwise ask.
2. **Detect plan structure**:
   - **Per-file** (`SESSION_1.md`, `SESSION_2.md`, …): each session is its own file. Implementer gets the file path.
   - **Single inline plan**: sessions are top-level `## Session N` (or `## Phase N`) headings. Extract the current heading's section as text, and also hand the implementer the plan path so it can read siblings if it needs surrounding context.
   - If neither pattern matches cleanly, ask the user which heading or file corresponds to the current session before proceeding.
3. **Read the plan yourself** — just enough to (a) pick the right domain specialist and (b) know when there are no more sessions. Don't try to summarize the plan for the implementer; the implementer reads it in full.
4. **Create the stacked branch** (see Git workflow).
5. **Create todos** for this session's 3 phases.

## Git workflow: stacked PRs

Same as `/implement`. Each session branches off the previous session's branch (or `main` for session 1). PR created after Phase 1, marked ready after Phase 3.

**Always use worktrees.** Each session gets its own isolated directory. This is required — not optional — because the `Agent` tool spawns implementers with the coordinator's current CWD, not the path written in the prompt. Using worktrees and `EnterWorktree` is the only way to guarantee commits land on the right branch.

```bash
# Session N
git worktree add .claude/worktrees/session-N-{feature} -b session-N-{feature} {previous-branch-or-main}
```

Then immediately call `EnterWorktree path=.claude/worktrees/session-N-{feature}` **before** spawning the implementer. This pins the implementer's inherited CWD to the new branch.

## Pipeline: 3 phases

### Phase 1: Implement (+ inline simplify + inline docs)

Select the best domain specialist you can find (`pro:react-native-pro`, `pro:typescript-pro`, `pro:backend-dev`, etc.). Fall back to `general-purpose` if none fit or the specialist isn't installed.

```
Task tool:
  subagent_type: {SPECIALIST_OR_general-purpose}
  prompt: |
    Implement the session plan at: {SESSION_PLAN_PATH}
    {IF INLINE PLAN: The section for this session is titled "{PHASE_TITLE}"; implement only that section.}

    Working directory: {WORKTREE_PATH}
    Expected branch: {SESSION_BRANCH_NAME}

    **FIRST ACTION — do this before reading any file or writing any code:**
    Run: git branch --show-current
    If the output is NOT "{SESSION_BRANCH_NAME}", run: cd {WORKTREE_PATH} && git branch --show-current
    If it still isn't "{SESSION_BRANCH_NAME}", abort and report "Wrong branch: <actual>" — do not commit.

    Read the plan (or the named section) thoroughly, then implement all changes.

    Style expectations (do these inline; there is no separate simplify pass):
    - Write simple, direct code. No premature abstraction.
    - No dead code, no speculative flags, no scaffolding for imaginary future needs.
    - Follow the codebase's existing patterns.

    Documentation expectations (do these inline; there is no separate docs pass):
    - Update relevant CLAUDE.md files if you change architecture or introduce a pattern.
    - Do NOT create new README files unless the plan explicitly requires it.
    - Inline comments only where the WHY is non-obvious.

    Run tests: use the command the plan specifies, or the project's default
    test command if none is specified. Commit with a descriptive message.

    Report:
    - What you implemented (short).
    - The branch you committed to (output of: git branch --show-current after committing).
    - Any deviations from the plan and why.
    - Any blockers.
```

**Capture the implementer's `agentId`** from the Task result — the spawn output includes it in the form `agentId: a...-...`. You'll need it for Phase 3 `SendMessage`. If you lose track, call `ListAgents` to find it.

**Branch landing check:** After Phase 1 completes, verify the commit is on the right branch:

```bash
git log --oneline {SESSION_BRANCH_NAME} | head -1
# should show the implementer's commit message
```

If the commit landed on the wrong branch (e.g. the previous session's branch):

```bash
# Merge it forward into the correct branch
git merge {PREVIOUS_BRANCH} --no-edit
# Then push and continue
```

This is a known failure mode when the agent tool inherits the coordinator's CWD rather than the worktree path given in the prompt. The merge-forward recovers cleanly without rebasing or force-pushing.

### Phase 1.5: PR creation (coordinator bash, no agent)

Do this yourself. Do not spawn an agent for it.

```bash
git push -u origin {BRANCH_NAME}
gh pr create --draft --base {TARGET_BRANCH} \
  --title "Session N: {short description}" \
  --body "$(cat <<'EOF'
{IMPLEMENTER_REPORT_FROM_PHASE_1}

---
Draft PR. Will be marked ready after review passes.
EOF
)"
```

Use the implementer's Phase 1 report verbatim as the body. It already summarizes what was implemented, deviations, and blockers.

### Phase 2: Review (loop; isolation preserved)

Each review is a **fresh agent** — this is where isolation earns its keep.

**Isolation guardrail** (do not violate under any circumstance, including token pressure or "just to save a round"):

- Do NOT include prior reviewer findings, verdicts, or paraphrases of them.
- Do NOT tell the reviewer this is iteration N, or that a fixup was just applied.
- Do NOT hint at what the previous reviewer thought was OK.
- Every review invocation uses the SAME clean prompt — only the diff changes between iterations.

Prefer the `/code-review` skill if installed. Otherwise:

```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    Review the current diff against the session plan at: {SESSION_PLAN_PATH}
    {IF INLINE PLAN: Focus on the section titled "{PHASE_TITLE}".}
    Read the full plan (or section). Do not accept any coordinator-side
    summary in place of it.

    ## Severity

    **BLOCKING** — wrong behavior, security issues, unplanned architectural
    divergence, skipped plan steps without justification.

    **MAJOR** — edge case bugs, missing error handling, unexplained
    implementation divergence.

    **MINOR** — style, naming. Do NOT block on these.

    ## Verdict (exactly one)

    - "APPROVED" — no blocking or major issues.
    - "APPROVED_WITH_NOTES" — no blocking/major; minor notes: [list].
    - "NEEDS_WORK" — blocking or major issues: [list with file:line].

    Implementation matching the plan with working tests is APPROVED even if
    imperfect. Perfectionism wastes tokens.
```

### Phase 3: Fixup (conditional; SAME implementer via SendMessage)

If Phase 2 returns `NEEDS_WORK`, do NOT spawn a new Task. Send a message to the original implementer, who already has the plan and codebase context loaded.

```
SendMessage tool:
  to: {IMPLEMENTER_AGENT_ID_FROM_PHASE_1}
  message: |
    Fix each issue below. Run tests. Commit. Report what changed.

    {REVIEW_ISSUES_VERBATIM}
```

If `SendMessage` is deferred, load it first:

```
ToolSearch: "select:SendMessage,ListAgents"
```

If the original implementer is no longer reachable (rare — e.g., its context expired), fall back to a fresh Task with the same specialist and a distilled brief: the plan path, the review findings, and the list of files it touched.

### Review loop

```
iteration = 0
REPEAT:
    iteration += 1
    Run Phase 2 review (fresh agent)

    IF APPROVED or APPROVED_WITH_NOTES:
        EXIT ✓

    IF NEEDS_WORK:
        Run Phase 3 fixup (SendMessage to implementer)
        IF iteration >= 2:
            Assess how close the last review was to APPROVED and recommend:
            - Only MINOR issues left, or 1-2 bounded fixes → recommend "ship + track leftovers"
            - Real blockers still surfacing → recommend "keep iterating"
            - Reviewer bouncing on different things each round → recommend "escalate to me"
            AskUserQuestion with your recommendation as option 1.
            Act on response.
        GOTO REPEAT
```

**Iteration cap is 2** (down from 4 in `/implement`). Fresh reviewer cold-starts are the dominant remaining cost. At the cap the coordinator recommends a path on a case-by-case basis rather than looping blindly.

## Optional passes (case-by-case, coordinator's judgment)

After the review loop exits APPROVED, decide whether the change earns a dedicated **docs pass**. Recommend one via `AskUserQuestion` if any of these hold:

- Architecture or a shared pattern changed (new module, changed data flow, new abstraction).
- Multiple `CLAUDE.md` files would need updates.
- The plan explicitly called out user-facing documentation.
- The implementer's Phase 1 report explicitly said "docs update pending" or similar.

Skip silently for small or self-contained changes. When the user approves a docs pass, spawn one fresh general-purpose agent:

```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    Read the diff on the current branch. Update the CLAUDE.md files (and any
    other docs) that are now stale as a result. Do NOT create new READMEs.
    Commit the doc updates with message "docs: update after {session name}".
    Report which files you updated.
```

Do not spawn this by default. The whole point of implement-lite is not paying for agents that mostly re-read a diff.

## Session completion

```bash
git push
gh pr ready
```

Report the PR link to the user.

## Multi-session loop

After finishing a session, check for the next one:

- Look for `SESSION_{N+1}.md`, `SESSION_{N+1}_PLAN.md`, or the next phase section in an inline plan.
- If found: return to Setup, create a new branch stacked on this session's branch, run the 3-phase pipeline again.
- If not: EXIT ✓.

Do not stop after session 1 unless it's clearly the only one.

## Todo tracking

Per session:

```
Session N:
- [ ] Phase 1: Implement (+ inline simplify + docs)
- [ ] Phase 1.5: Create draft PR (coordinator bash)
- [ ] Phase 2/3: Review loop (max 2 iterations, fixup via SendMessage)
- [ ] Optional: docs pass (only if architectural — coordinator recommends)
- [ ] Mark PR ready
- [ ] Check for next session
```

## Error handling

- **Specialist agent not found** — retry with `general-purpose`.
- **Implementer unreachable for fixup** — fall back to fresh Task; see Phase 3.
- **Reviewer keeps returning NEEDS_WORK past iteration 2** — escalate to user; do not keep looping silently.
- **Branch conflict on push** — append timestamp suffix, retry once.
- **`gh pr create` fails** — report the error and the manual command; don't block the pipeline.
- **Push rejected** — pull with rebase, retry once, then ask user.
- **Not logged into gh** — ask user to run `gh auth login`.
- **Implementer committed to wrong branch** — run the branch landing check (see above); merge the previous branch forward into the session branch; do not rebase or force-push already-pushed branches. Prevent recurrence by entering the new worktree (`EnterWorktree`) before spawning the next implementer.

Never force-push. Never amend commits from previous sessions.

## What this skill deliberately does NOT do

- **No separate simplify agent.** The implementer is told to write simple code the first time.
- **No default docs agent.** The implementer handles `CLAUDE.md` inline. A dedicated docs pass is coordinator-recommended only when the change is architectural or cross-cutting (see Optional passes).
- **No agent for PR creation.** Coordinator bash, body seeded from the implementer's Phase 1 report.
- **No blind loop past iteration 2.** At the cap, the coordinator assesses the last review and recommends ship / iterate / escalate — case by case, not a fixed prompt.
- **No summarization of the session plan.** The plan is the spec; the implementer reads it in full.
- **No cross-iteration reviewer priming.** Every review is a fresh agent with a clean prompt (see the isolation guardrail in Phase 2).

---

**Start now.** Ask for the session plan path if not provided.
