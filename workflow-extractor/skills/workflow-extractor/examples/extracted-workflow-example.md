# Example: Extracted Workflow Skill

This shows what an extracted workflow skill looks like. This example is the
`prompt-review` skill that was extracted from an ad-hoc prompt improvement
session.

## The Original Session

The user asked for help improving an LLM prompt. Through the conversation:

1. Claude asked about the prompt's purpose and context
2. Created a structured file to track the review
3. Used a prompt-pro agent for initial analysis
4. Used a second prompt-pro agent to validate findings
5. Applied approved changes to the source file
6. Verified the changes were correct
7. Committed with a descriptive message

This pattern emerged organically and worked well.

## Why It Qualified for Extraction

| Criterion         | Evidence                                |
| ----------------- | --------------------------------------- |
| Multi-step (3+)   | 7 coordinated phases                    |
| Structure emerged | Review file format, dual-review pattern |
| Repeatable        | Works for any prompt in any project     |
| Validated         | Successfully improved the prompt        |
| Non-trivial       | Novel multi-agent coordination pattern  |

## The Extracted Skill

```yaml
---
name: prompt-review
description: |
  Review and improve LLM prompts using a multi-agent workflow. Guides you
  through setup, review file creation, and the improvement pipeline. Use
  when working with LLM prompts.
argument-hint: "[file] [--reset] [--new]"
disable-model-invocation: true
---

# Prompt Review

A progressive, multi-agent workflow for reviewing and improving LLM prompts.

## How It Works

### State Detection

1. Check for config: Look for `.prompt-review.yaml` in project root
2. Check for review files: Look for `*_review.md` files
3. Check for prompts: Scan for prompt files if patterns configured
4. Check arguments: User may have provided a specific file or flags

### Progressive Flow

/prompt-review (no setup) → Interview → Create config
/prompt-review (setup, no reviews) → Select prompt → Create review file
/prompt-review (reviews exist) → Select review → Run pipeline
/prompt-review path/to/review.md → Run pipeline directly

## The Pipeline

### Step 1: Initial Review (prompt-pro A)
Pass review file to prompt-pro agent for initial analysis.

### Step 2: Secondary Review (prompt-pro B)
Pass Agent A's output to second prompt-pro for validation.

### Step 3: Implementation (general-purpose C)
Apply approved changes to source file.

### Step 4: Verification (general-purpose D)
Verify changes match approved version.

### Step 5: Commit
Commit changes with descriptive message.

## Coordinator Behavior

- Assess state, guide user through appropriate flow
- Delegate to subagents, don't perform reviews yourself
- Handle errors by restarting failed steps
- Provide summary after completion
```

## Key Observations

1. **State detection**: The skill handles different entry points gracefully
2. **Progressive flow**: Users aren't overwhelmed with options
3. **Agent delegation**: Coordinator orchestrates, doesn't do the work
4. **Supporting files**: Templates and examples extracted alongside the skill

## What Wasn't Extracted

The specific prompts being reviewed, the exact review feedback, the debugging
that happened along the way—these are **knowledge**, not workflow. If there were
debugging insights worth preserving, those would go to `continuous-learning`
instead.
