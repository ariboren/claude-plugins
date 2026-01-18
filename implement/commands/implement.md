---
description: Coordinate implementation of a multi-session project using subagents
argument-hint: <session-plan-path>
allowed-tools: Task, Bash, TodoWrite, AskUserQuestion
model: opus
---

# Implement: Session Implementation Pipeline

You are a **coordinator only**. Orchestrate a 5-step agent pipeline for each session—do NOT implement, review, or document anything yourself.

## Coordinator Rules

- **NEVER** read code, write code, or analyze implementations yourself
- **ONLY** use Task tool to launch agents, TodoWrite to track progress, Bash for git/PR operations
- Keep messages brief—state what you're doing and launch the next agent
- Each step uses a **distinct agent** for fresh context

## Setup

1. If `$ARGUMENTS` provided, use it as the session plan path
2. Otherwise, ask user for the session plan path (e.g., `docs/projects/NN-feature/SESSION_1_PLAN.md`)
3. Create stacked branch for this session (see Git Workflow below)

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

Create PR after each session completes, targeting the previous session's branch (or main for session 1).

## Pipeline: 5 Steps Per Session

Execute these steps sequentially. Each step is a **separate agent** for isolation.

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

### Step 2: Simplify

```
Task tool:
- subagent_type: "code-simplifier"
- model: "sonnet"
- prompt: |
    Review and simplify the code changes from the recent implementation.

    Focus on:
    - Removing unnecessary complexity
    - Improving readability
    - Eliminating duplication
    - Ensuring consistent style

    Make changes directly. Commit if you made improvements.
    Report what you simplified (or confirm code is already clean).
```

### Step 3: Review

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

Only run if Step 3 outputs "REVIEW_FAILED":

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

1. Push the branch
2. Create PR targeting the previous session's branch (or main for session 1)
3. Report session complete with PR link

```bash
git push -u origin {BRANCH_NAME}
gh pr create --base {TARGET_BRANCH} --title "Session N: {description}" --body "..."
```

## Todo Tracking

Create todos at session start:

```
- [ ] Step 1: Implementation
- [ ] Step 2: Simplify
- [ ] Step 3: Review
- [ ] Step 4: Fixup (if needed)
- [ ] Step 5: Documentation
- [ ] Create PR
```

Update as each step completes.

## Error Handling

- If any agent reports being blocked, use AskUserQuestion to get guidance
- If tests fail repeatedly, ask user whether to proceed or abort
- After 3 fixup cycles without REVIEW_PASSED, escalate to user

---

**Start now.** Ask for the session plan path if not provided.
