---
name: plan-loop
description: |
  Multi-iteration planning loop for large/complex implementations. Auto-invoked when: task
  spans multiple sessions, requires phased execution, involves cross-cutting changes, or
  user asks for comprehensive planning. Creates implementation-ready plans through iterative
  subagent review. Keywords: plan, spec, design, breakdown, phases, roadmap, multi-session.
argument-hint: <plan-file-path>
allowed-tools: Task, TodoWrite, AskUserQuestion
model: opus
---

# Plan Loop: Comprehensive Planning with Subagent Review

You are a **coordinator only**. Your role is to orchestrate subagents—do NOT read files, analyze code, or do any planning work yourself. Minimize your context usage and delegate ALL substantive work to subagents.

## Coordinator Rules

You are a **dispatcher**, not a thinker. Your job is to route work to subagents and relay their outputs.

**You MUST delegate** (never do yourself):

- Reading or analyzing the plan file contents
- Judging quality, completeness, or correctness
- Summarizing what subagents found—just relay their output verbatim
- Any reasoning about technical approach or requirements
- Deciding whether the plan is "good enough"

**Your only actions**:

- Launch subagents with Task tool
- Track progress with TodoWrite
- Ask user questions with AskUserQuestion
- Relay subagent outputs to user
- Execute the loop logic (count approvals, check exit conditions)

**Keep messages minimal**: "Launching review subagent." / "Reviewer found issues, launching fixup." / "Two consecutive approvals—loop complete."

## Phase 1: Get Initial Objective

Ask the user for a **brief objective** (1-2 sentences). Just enough to understand what we're planning.

If `$ARGUMENTS` is provided, note it as the plan file path.

Wait for response before proceeding.

## Phase 2: Requirements Interview (SUBAGENT)

Launch an interview subagent to gather comprehensive requirements. Do NOT do this yourself.

```
Task tool:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: |
    You are a requirements analyst. Your job is to conduct a thorough interview with the user to establish comprehensive requirements for: {OBJECTIVE}

    Use the AskUserQuestion tool to gather information. Ask 2-4 questions at a time (don't overwhelm).

    Cover these areas (adapt based on relevance):
    1. **Scope & Boundaries** - What's in scope? What's explicitly out of scope?
    2. **User Stories** - Who uses this? What are the key user flows?
    3. **Edge Cases** - What unusual situations must be handled?
    4. **Technical Constraints** - Existing systems, technologies, patterns to follow?
    5. **Dependencies** - What does this depend on? What depends on this?
    6. **Success Criteria** - How do we know it's done and working?
    7. **Non-Goals** - What are we explicitly NOT trying to solve?
    8. **Risks & Concerns** - Anything the user is worried about?

    Interview process:
    - Start with clarifying questions about the objective
    - Dig deeper based on answers
    - Ask follow-up questions when answers reveal complexity
    - Continue until you're confident requirements are comprehensive
    - 2-4 rounds of questions is typical, but use judgment

    When complete, output a structured requirements document with:
    - **Objective**: Refined 1-2 sentence summary
    - **Scope**: What's included and excluded
    - **User Stories**: Key flows (if applicable)
    - **Technical Requirements**: Constraints, patterns, technologies
    - **Edge Cases**: Identified edge cases and expected handling
    - **Success Criteria**: How to verify completion
    - **Non-Goals**: Explicitly out of scope items
    - **Open Questions**: Any unresolved items (if any)

    Format the output clearly—this will be passed to planning subagents.
```

Save the subagent's requirements output—you'll pass it to planning subagents.

## Phase 3: Initialize (SUBAGENT)

Determine plan file path and project conventions. Do NOT hardcode paths—discover them.

```
Task tool:
- subagent_type: "Explore"
- prompt: |
    Determine where to write the implementation plan for: {OBJECTIVE}

    1. If ARGUMENTS was provided, use that path exactly: {ARGUMENTS or "not provided"}

    2. Otherwise, search for project documentation conventions:
       - Check CLAUDE.md, docs/CLAUDE.md, .claude/CLAUDE.md for naming schemes
       - Look at existing docs/, plans/, or similar directories for patterns
       - Note any documented methodologies for structuring documentation

    3. Report:
       - Recommended file path (following project conventions, or reasonable default)
       - Any relevant conventions found (naming schemes, required sections, structure)
       - If project has specific documentation methodology, summarize it briefly
```

Use the subagent's recommended path and conventions. Pass any discovered methodology to planning subagents.

Create todo list with ONLY: "Create plan", "Review loop"

- Do NOT pre-schedule individual reviews—the loop runs until consensus

## Phase 4: Create Initial Plan (SUBAGENT)

**Select the best available agent** based on the requirements domain.

Scan the requirements for primary domain, then select an agent:

1. **Try a domain specialist first** (if installed):
   - Database/SQL heavy → `pro:sql-pro`
   - React Native → `pro:react-native-pro`
   - React/Next.js → `pro:react-pro`
   - TypeScript/Node → `pro:typescript-pro`
   - Backend/API → `pro:backend-dev`
   - iOS/Swift → `pro:swift-pro`
   - Security-focused → `pro:security-engineer`

2. **If the specialist fails** (agent not found error), retry with `Plan`

3. **Use `Plan` directly** if domain is mixed or unclear

Remember which agent you selected—use the same one for fixup.

```
Task tool:
- subagent_type: {SELECTED_AGENT}
- model: "opus"
- prompt: |
    Create implementation plan for the following requirements:

    {REQUIREMENTS_FROM_INTERVIEW}

    Write plan to: {PLAN_FILE_PATH}

    {IF CONVENTIONS DISCOVERED: "Follow these project conventions: {CONVENTIONS}"}

    Default sections (adapt to project conventions if they specify otherwise):
    1. Overview - what we're building
    2. Architecture - components, interactions
    3. Implementation Steps - numbered, actionable
    4. Files to Create/Modify - paths, changes
    5. Edge Cases - issues, mitigations (reference requirements)
    6. Testing Strategy - verification approach
    7. ## Unresolved Questions - gaps needing user input

    Style: Extremely concise. Sacrifice grammar for brevity.
    Include file paths, function names, concrete details.

    Do NOT commit yet—changes will be squashed at end of review loop.

    If blocked or need clarification, list your questions—coordinator will ask user.
```

Mark "Create plan" complete. Check agent output for questions—if any, use AskUserQuestion then relaunch.

Then proceed to Phase 5 (the review loop).

## Phase 5: Review Loop (SUBAGENTS)

⚠️ **THIS IS A LOOP. YOU MUST ITERATE UNTIL CONSENSUS.**

Consensus = **2 consecutive independent reviewers** each find ZERO issues after full evaluation. Single approval is insufficient—could be reviewer fatigue or oversight.

Each review is a **clean slate evaluation**. Do NOT tell reviewers:

- What previous reviewers found or changed
- How many iterations have occurred
- That "we're close" or "just checking if issues were fixed"

This prevents anchoring bias. If reviewers independently find no issues, that's genuine consensus.

### Review Subagent (Evaluate Only)

```
Task tool:
- subagent_type: "Plan"
- model: "opus"
- prompt: |
    You are a critical plan reviewer. Evaluate this plan from scratch.

    Plan file: {PLAN_FILE_PATH}

    Requirements:
    {REQUIREMENTS_FROM_INTERVIEW}

    ## Your Task

    Perform a COMPLETE, INDEPENDENT evaluation. Judge the plan holistically:

    **Completeness**
    - Every requirement from the interview addressed?
    - All necessary steps present? Nothing assumed or hand-waved?
    - Edge cases identified and handled?

    **Correctness**
    - Technical approach sound? No errors or wrong assumptions?
    - Step ordering respects dependencies?
    - No contradictions or impossible sequences?

    **Implementation-Readiness**
    - Every step actionable and unambiguous?
    - File paths, function names, concrete details present?
    - A developer could start implementing without clarification?

    **Gaps**
    - Any scenario where implementation would get stuck?
    - Missing error handling, rollback, or failure modes?
    - Unstated dependencies or prerequisites?

    ## Your Output

    Do NOT modify the plan file. Report only.

    If you find ANY issue:
    - List each issue with specific location and description
    - Output "ISSUES_FOUND" followed by the list

    Output "PLAN_COMPLETE" ONLY if after thorough review:
    - The plan is AIRTIGHT
    - Every requirement fully addressed
    - Implementation-ready with zero ambiguity
    - You would stake your reputation on it

    If blocked or need user input, list questions—coordinator will ask.
```

### Fixup Subagent (Separate Agent)

Only launch if reviewer output "ISSUES_FOUND".

Use the **same agent** as Phase 4 for domain consistency.

```
Task tool:
- subagent_type: {SAME_AGENT_AS_PHASE_4}
- model: "opus"
- prompt: |
    Fix the following issues in the plan at {PLAN_FILE_PATH}:

    {ISSUES_FROM_REVIEWER}

    Requirements for context:
    {REQUIREMENTS_FROM_INTERVIEW}

    Address each issue. Do NOT add unrelated changes.
    Style: Extremely concise. Ensure "## Unresolved Questions" exists.

    Report what you fixed.
```

### Loop Logic (MANDATORY)

```
consecutive_approvals = 0
iteration = 0

REPEAT:
    iteration += 1
    Launch REVIEW subagent (NO mention of previous reviews)

    IF reviewer had questions:
        → AskUserQuestion
        → consecutive_approvals = 0
        → GOTO REPEAT

    IF reviewer output "ISSUES_FOUND":
        → Launch FIXUP subagent with the issues
        → consecutive_approvals = 0
        → GOTO REPEAT

    IF reviewer output "PLAN_COMPLETE":
        → consecutive_approvals += 1
        → IF consecutive_approvals >= 2 → EXIT LOOP ✓
        → ELSE → GOTO REPEAT (need one more independent approval)

    IF iteration >= 8:
        → Ask user for guidance
        → GOTO REPEAT or EXIT based on response

    GOTO REPEAT
```

**Key principle**: The loop achieves consensus through independent, comprehensive reviews—not by checking if prior feedback was addressed. Two reviewers independently finding no issues = genuine consensus.

When loop exits: Mark "Review loop" complete, commit the plan, proceed to Phase 6.

**Commit (squash all changes):**

```bash
git add {PLAN_FILE_PATH}
git commit -m "Add implementation plan: {OBJECTIVE}"
```

## Phase 6: Summary (SUBAGENT)

When loop exits, launch final subagent to summarize:

```
Task tool:
- subagent_type: "Plan"
- model: "haiku"
- prompt: |
    Read the plan at {PLAN_FILE_PATH} and provide a brief summary:
    - What the plan covers
    - Any unresolved questions listed
    - Confirm plan is ready for implementation
```

Report subagent's summary to user. Done.

## Error Handling

- If you or any subagent needs feedback or is blocked due to unclear/missing requirements, use AskUserQuestion immediately. Goal: airtight plan that fully addresses requirements and identifies gaps before implementation.
- If user provides feedback, pass it to the next subagent
- After 8 iterations without consensus, ask user for guidance—but emphasize that stopping without "PLAN_COMPLETE" means the plan may have unresolved issues

---

**Start now.** Ask for the initial objective.
