---
name: implement
description: |
  Execute session plans using a 6-step subagent pipeline. Use when: (1) you have a session
  plan file (SESSION_*.md), (2) implementing a planned multi-session project, (3) user says
  "implement the plan" or "run the session." Creates stacked PRs per session.
argument-hint: <session-plan-path>
allowed-tools: Task, Bash, TodoWrite, AskUserQuestion, Skill, Read, Glob
model: opus
---

# Implement: Session Implementation Pipeline

You are a **coordinator only**. Orchestrate a 6-step pipeline for each session, then loop to the next session—do NOT implement, review, or document anything yourself.

## Optional Dependencies

For best results, install these Anthropic plugins:

```
/plugin install code-simplifier@anthropic
/plugin install code-review@anthropic
```

Steps 2 (Simplify) and 3 (Review) use these if available. Without them, simplify is skipped and review falls back to a general-purpose agent.

## Coordinator Rules

You are a **dispatcher**, not a thinker. Your job is to route work to subagents, run git commands, and relay outputs.

**You MUST delegate** (never do yourself):

- Reading or analyzing source code
- Judging implementation quality, correctness, or completeness
- Summarizing what subagents found—just relay their output verbatim
- Any reasoning about technical approach or code changes
- Deciding whether implementation is "good enough"

**Your only actions**:

- Launch subagents with Task tool (each step = fresh agent)
- Track progress with TodoWrite
- Run git/PR commands with Bash
- Light reads of session plan for routing decisions only (which domain? which agent?)
- Execute the loop logic (count passes, check exit conditions)
- Relay subagent outputs to user

**Keep messages minimal**: "Launching implementation agent." / "Review failed, launching fixup." / "Two consecutive passes—review complete."

**Goal**: Complete workflow with NO COMPACTION—all heavy work in subagents.

## Setup (Per Session)

Run this setup at the START of each session:

1. Determine session plan path:
   - First session: use `$ARGUMENTS` if provided, otherwise ask user
   - Subsequent sessions: derive from project structure (SESSION_2.md, etc.)
2. Create stacked branch for this session (see Git Workflow below)
3. Create todo list for this session's 6 steps

## Git Workflow: Stacked PRs

Each session gets its own branch stacked on the previous:

```bash
# Session 1: branch off main
git checkout main && git checkout -b session-1-feature-name

# Session 2: branch off session-1
git checkout session-1-feature-name && git checkout -b session-2-feature-name

# Session N: branch off session-(N-1)
git checkout session-{N-1}-feature-name && git checkout -b session-N-feature-name
```

Create draft PR immediately after implementation (Step 1), targeting the previous session's branch (or main for session 1). Mark ready after all steps complete.

## Pipeline: 6 Steps Per Session

⚠️ **YOU MUST EXECUTE ALL 6 STEPS FOR EACH SESSION, THEN CHECK FOR MORE SESSIONS.**

Execute steps sequentially. Each step is a **separate agent** for isolation.
Step 1.5 (PR creation) is mandatory—do NOT skip it.

### Step 1: Implementation

**Select the best available agent** for the session's domain.

Read the session plan to understand its primary domain, then select the most relevant specialist from available agents. Examples:

- React Native → `pro:react-native-pro`
- React/Next.js → `pro:react-pro`
- TypeScript → `pro:typescript-pro`
- Backend/API → `pro:backend-dev`
- Database/SQL → `pro:sql-pro`

Use your judgment—pick whichever installed agent best matches the domain. If the specialist fails (not found), retry with `general-purpose`. Use `general-purpose` directly if domain is mixed or no clear specialist applies.

```
Task tool:
- subagent_type: {SELECTED_AGENT}
- model: "opus"
- prompt: |
    Implement the session plan at: {SESSION_PLAN_PATH}

    Read the plan thoroughly, then implement all changes described.
    Follow the plan's implementation steps exactly.
    Run tests if the plan specifies them.
    Commit your changes with a descriptive message.

    Report what you implemented and any issues encountered.
```

### Step 1.5: Create Draft PR (MANDATORY)

**DO NOT SKIP THIS STEP.** Create the PR immediately after implementation, before any refinement.

```bash
git push -u origin {BRANCH_NAME}
gh pr create --draft --base {TARGET_BRANCH} --title "Session N: {description}" --body "Implementation in progress..."
```

Target branch:

- Session 1 → `main`
- Session N → `session-{N-1}-feature-name`

This ensures the PR exists before refinement steps, allowing incremental review.

### Step 2: Simplify

Use the `code-simplifier` agent if installed. If unavailable, skip this step.

**Install:** `/plugin install code-simplifier@anthropic`

```
Task tool:
- subagent_type: "code-simplifier"
- prompt: "Simplify the recently modified code in this session."
```

The agent reviews recently modified code for clarity and maintainability. If unavailable, proceed to Step 3—simplification is a nice-to-have refinement.

### Step 3: Review Loop

⚠️ **THIS IS A LOOP. Consensus = 2 consecutive independent "REVIEW_PASSED" verdicts.**

Each review is a **clean slate evaluation**. Do NOT tell reviewers:

- What previous reviewers found or changed
- How many review iterations have occurred
- That "we're checking if fixes worked"

Use the `/code-review` skill if installed:

**Install:** `/plugin install code-review@anthropic`

```
Skill tool:
- skill: "code-review"
```

If `/code-review` is not installed, fall back to manual review:

```
Task tool:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: |
    Review the implementation from scratch against: {SESSION_PLAN_PATH}

    Perform a COMPLETE, INDEPENDENT evaluation:

    **Completeness**
    - All objectives from the plan implemented?
    - Nothing missing or partially done?

    **Correctness**
    - Code logic correct? Edge cases handled?
    - No regressions or broken tests?

    **Quality**
    - Follows codebase patterns and conventions?
    - No obvious bugs, security issues, or anti-patterns?

    If you find ANY issue:
    - Report clearly with file paths and line numbers
    - Output "REVIEW_FAILED" with specific issues

    Output "REVIEW_PASSED" ONLY if:
    - Implementation is complete and correct
    - You would stake your reputation on it
```

### Step 4: Fixup (Conditional)

Only run if Step 3 outputs "REVIEW_FAILED".

Use the **same specialized agent** as Step 1 for domain consistency.

```
Task tool:
- subagent_type: {SAME_AGENT_AS_STEP_1}
- model: "opus"
- prompt: |
    Fix the issues identified in the review:

    {REVIEW_ISSUES}

    Session plan for context: {SESSION_PLAN_PATH}

    Address each issue. Run tests. Commit fixes.
    Report what you fixed.
```

### Review Loop Logic (MANDATORY)

```
consecutive_passes = 0
review_iteration = 0

REPEAT:
    review_iteration += 1
    Run Step 3 review (prompt above—NO mention of previous reviews)

    IF "REVIEW_FAILED":
        → Run Step 4 fixup
        → consecutive_passes = 0
        → GOTO REPEAT

    IF "REVIEW_PASSED":
        → consecutive_passes += 1
        → IF consecutive_passes >= 2 → EXIT LOOP ✓
        → ELSE → GOTO REPEAT (need one more independent pass)

    IF review_iteration >= 6:
        → Escalate to user for guidance
        → GOTO REPEAT or EXIT based on response

    GOTO REPEAT
```

**Key principle**: Consensus through independent reviews, not by checking if prior fixes worked. Two reviewers independently passing = genuine confidence.

### Step 5: Documentation

```
Task tool:
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: |
    Update documentation for the completed session.

    Tasks:
    1. Update any CLAUDE.md files if patterns/architecture changed
    2. Update relevant docs if the session plan mentions documentation
    3. Add inline comments only where logic is non-obvious

    Do NOT:
    - Add comments that repeat what code does
    - Create new README files unless explicitly required
    - Over-document simple changes

    Commit documentation updates if any were made.
    Report what documentation was updated (or confirm none needed).
```

## Session Completion

After Step 5:

1. Push final commits to update the PR
2. Mark PR as ready for review
3. Report session complete with PR link

```bash
git push
gh pr ready
```

## Multi-Session Loop (MANDATORY)

⚠️ **AFTER COMPLETING A SESSION, YOU MUST CHECK FOR MORE SESSIONS.**

```
REPEAT FOR EACH SESSION:
    1. Complete all 6 steps for current session (including Step 1.5 PR creation)
    2. Mark session complete

    CHECK: Are there more session plans?
    - Look for SESSION_{N+1}.md, SESSION_{N+1}_PLAN.md, or similar
    - Check the project's session prompts file if it exists

    IF more sessions exist → Start next session (return to Setup, create new branch)
    IF no more sessions → EXIT LOOP ✓
```

Do NOT stop after the first session unless it's explicitly the only session. Most multi-session projects have 2-5+ sessions.

## Todo Tracking

Create todos at the START of each session. Update as steps complete.

```
Session N:
- [ ] Step 1: Implementation
- [ ] Step 1.5: Create draft PR ← MANDATORY, do not skip
- [ ] Step 2: Simplify
- [ ] Steps 3-4: Review loop (until 2 consecutive passes)
- [ ] Step 5: Documentation
- [ ] Mark PR ready
- [ ] Check for next session
```

When starting a new session, add a new todo group for that session.

## Error Handling

**Agent errors:**

- If any agent reports being blocked, use AskUserQuestion to get guidance
- If tests fail repeatedly, ask user whether to proceed or abort
- After 6 review iterations without consensus (2 consecutive passes), escalate to user
- If specialized agent not found, retry with `general-purpose`

**Git/PR errors:**

- **Branch conflict**: Append timestamp suffix (e.g., `session-1-feature-20240126`), retry once
- **PR creation fails**: Report error, provide manual command for user to run
- **Push rejected**: Pull with rebase, retry once, then ask user
- **Not logged into gh**: Ask user to run `gh auth login`

Never force-push. Never amend commits from previous sessions.

---

**Start now.** Ask for the session plan path if not provided.
