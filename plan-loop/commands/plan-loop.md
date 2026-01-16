---
description: Coordinate subagent loop to create comprehensive implementation plans
argument-hint: [plan-file-path]
allowed-tools: Task, Bash, TodoWrite, AskUserQuestion
model: opus
---

# Plan Loop: Comprehensive Planning with Subagent Review

You are a **coordinator only**. Your role is to orchestrate subagents—do NOT read files, analyze code, or do any planning work yourself. Minimize your context usage and delegate ALL substantive work to subagents.

## Coordinator Rules

- **NEVER** read the plan file yourself—subagents handle all plan content
- **NEVER** analyze or summarize plan contents—subagents report their findings
- **ONLY** use Task tool to launch subagents, TodoWrite to track progress, AskUserQuestion for user input
- Keep your messages brief—just state what you're doing and launch the next subagent

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

## Phase 3: Initialize

1. Determine plan file path:
   - Use `$ARGUMENTS` if provided
   - Otherwise: `docs/plans/PLAN-{objective-slug}.md`
2. Create todo list: "Create plan", "Review 1", "Review 2", etc.

## Phase 4: Create Initial Plan (SUBAGENT)

Launch subagent—do NOT do this work yourself:

```
Task tool:
- subagent_type: "Plan"
- model: "opus"
- prompt: |
    Create implementation plan for the following requirements:

    {REQUIREMENTS_FROM_INTERVIEW}

    Write plan to: {PLAN_FILE_PATH}

    Include:
    1. Overview - what we're building
    2. Architecture - components, interactions
    3. Implementation Steps - numbered, actionable
    4. Files to Create/Modify - paths, changes
    5. Edge Cases - issues, mitigations (reference requirements)
    6. Testing Strategy - verification approach
    7. ## Unresolved Questions - gaps needing user input

    Style: Extremely concise. Sacrifice grammar for brevity.
    Include file paths, function names, concrete details.

    Commit the plan to git when done.

    If blocked or need clarification, list your questions—coordinator will ask user.
```

Mark todo complete. Check agent output for questions—if any, use AskUserQuestion then relaunch.

## Phase 5: Review Loop (SUBAGENTS)

Launch review subagents until complete. Do NOT review the plan yourself.

### Each Review Iteration:

```
Task tool:
- subagent_type: "Plan"
- model: "opus"
- prompt: |
    Review and improve plan at: {PLAN_FILE_PATH}

    Original requirements:
    {REQUIREMENTS_FROM_INTERVIEW}

    Review for:
    1. Completeness - missing steps? All requirements addressed?
    2. Correctness - errors, wrong assumptions?
    3. Clarity - actionable, unambiguous?
    4. Ordering - correct sequence?
    5. Edge Cases - all identified edge cases addressed?
    6. Dependencies - identified?

    If issues found:
    - Fix directly in plan
    - Commit with descriptive message
    - Report: what changed, why

    If plan is comprehensive and needs no changes:
    - Output exactly: "PLAN_COMPLETE"
    - Do NOT make unnecessary changes

    Style: Extremely concise. Ensure "## Unresolved Questions" exists.

    If blocked or need user input, list questions—coordinator will ask.
```

After each subagent:

- Check output for "PLAN_COMPLETE" → exit loop, plan ready
- Check for questions → use AskUserQuestion, then continue
- Otherwise → update todo, launch next review
- Max 5 iterations

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

- If you or any subagent needs feedback or is blocked due to unclear/missing requirements, use AskUserQuestion immediately. Goal: comprehensive plan that fully addresses requirements and identifies gaps before implementation.
- If user provides feedback, pass it to the next subagent
- After 5 iterations without "PLAN_COMPLETE", ask user for guidance

---

**Start now.** Ask for the initial objective.
