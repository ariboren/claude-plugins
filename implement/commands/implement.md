---
description: Coordinate implementation of a multi-session project using subagents
argument-hint: <session-plan-path>
allowed-tools: Task, Bash, TodoWrite, AskUserQuestion, Skill
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

- **NEVER** read code, write code, or analyze implementations yourself
- **ONLY** use Task tool to launch agents, TodoWrite to track progress, Bash for git/PR operations
- Keep messages brief—state what you're doing and launch the next agent
- Each step uses a **distinct agent** for fresh context

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

```
Task tool:
- subagent_type: "general-purpose"
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

### Step 3: Review

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
    Review the implementation against the session plan at: {SESSION_PLAN_PATH}

    Check:
    - All objectives from the plan are met
    - Code correctness and edge cases
    - No regressions or broken tests
    - Follows codebase patterns

    If issues found, report them clearly with file paths and line numbers.
    Output "REVIEW_PASSED" if implementation is complete and correct.
    Output "REVIEW_FAILED" with specific issues if problems exist.
```

### Step 4: Fixup (Conditional)

Only run if Step 3 outputs "REVIEW_FAILED" or review found issues:

```
Task tool:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: |
    Fix the issues identified in the review:

    {REVIEW_ISSUES}

    Session plan for context: {SESSION_PLAN_PATH}

    Address each issue. Run tests. Commit fixes.
    Report what you fixed.
```

If fixup was needed, re-run Step 3 (Review) to verify. Max 3 fixup cycles.

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
- [ ] Step 3: Review
- [ ] Step 4: Fixup (if needed)
- [ ] Step 5: Documentation
- [ ] Mark PR ready
- [ ] Check for next session
```

When starting a new session, add a new todo group for that session.

## Error Handling

- If any agent reports being blocked, use AskUserQuestion to get guidance
- If tests fail repeatedly, ask user whether to proceed or abort
- After 3 fixup cycles without REVIEW_PASSED, escalate to user

---

**Start now.** Ask for the session plan path if not provided.
