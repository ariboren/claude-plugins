---
name: prompt-review
description: |
  Review and improve LLM prompts using a multi-agent workflow. Use when: (1) optimizing
  prompts for production, (2) debugging prompt issues, (3) applying prompt engineering
  best practices. Runs dual-reviewer pipeline with quality + cost filtering.
argument-hint: "[file] [--reset] [--new]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite
disable-model-invocation: true
---

# Prompt Review

A progressive, multi-agent workflow for reviewing and improving LLM prompts.

## How It Works

When invoked, assess the current state and guide the user accordingly:

### State Detection

1. **Check for config**: Look for `.prompt-review.yaml` in project root
2. **Check for review files**: Look for `*_review.md` files (in config location or common paths)
3. **Check for prompts**: Scan for prompt files if patterns configured
4. **Check arguments**: User may have provided a specific file or flags

### Progressive Flow

```
/prompt-review
```

**If no setup exists:**

> "I don't see a prompt review setup for this project. I can help you:
>
> 1. Scan your codebase to find prompt files
> 2. Create a review file for a specific prompt
>
> Which would you like?"

Then: Launch setup subagent to interview user, create config, discover prompts.

**If setup exists but no review files:**

> "Found [N] prompt files but no review files yet. Which prompt would you like to review?"
>
> [List discovered prompts]

Then: Interview user about selected prompt, generate review file.

**If review files exist:**

> "Found these review files:
>
> - path/to/prompt1_review.md (not yet reviewed)
> - path/to/prompt2_review.md (reviewed 2024-01-15)
>
> Run a review, or create a new one?"

Then: Run 5-step pipeline on selected file.

**If specific file provided:**

```
/prompt-review path/to/review.md
```

Skip state detection, run pipeline directly.

### Escape Hatches

- `--reset`: Re-scan codebase, regenerate config (keeps existing review files)
- `--new`: Force new review file creation flow, skip to interview

## Configuration & Templates

See supporting files (do NOT load preemptively—reference only when needed):

- **[examples/prompt-review.yaml](examples/prompt-review.yaml)** - Config schema
- **[templates/review-template.md](templates/review-template.md)** - Review file format

## Setup Subagent

When `--new` flag OR no config exists, delegate setup to a subagent:

```
Task(subagent_type: "general-purpose", model: "sonnet")

Prompt: |
  You are setting up a prompt review workflow. Interview the user:

  1. Which prompt file to review? (validate it exists)
  2. What model does it run on?
  3. How often is it called? (high/moderate/low)
  4. Quality vs cost priority?
  5. Known issues? (optional)
  6. Edge cases that matter? (optional)

  Then create:
  - `.prompt-review.yaml` config if it doesn't exist
  - Review file in `.prompt-review/` directory using the template

  Keep questions focused. Skip optional fields if user wants to proceed quickly.
```

## Interview Questions (for subagent reference)

When creating a review file, ask:

1. **What does this prompt do?** (1-2 sentences)
2. **What model does it run on?**
3. **How often is it called?** (every request / moderate / rare)
4. **Quality vs cost priority?** (quality-focused / balanced / cost-sensitive)
5. **What problems have you noticed?** (optional)
6. **Any edge cases that matter?** (optional)

Use AskUserQuestion tool for structured input when possible.

## The 5-Step Review Pipeline

Once a review file exists, execute this pipeline:

### Agent Selection

Use this fallback chain for review agents:

1. **Try `pro:prompt-pro`** if available (from pro plugin)
2. **Fallback to `general-purpose`** with prompt engineering context

To check availability: the agent will error if not found—catch and retry with fallback.

### Reference Documentation

Before launching review agents, fetch these once per session (summarize to ~500 tokens each):

- https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices
- https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview

Pass summarized best practices to review agents. If fetch fails, proceed with built-in knowledge.

### Step 1: Initial Review (prompt-pro A)

```
Task(subagent_type: "pro:prompt-pro")  # fallback: "general-purpose"
```

Pass review file + reference docs. Instruct:

- NOT required to find issues if prompt is already high quality
- Apply honest judgment
- Consider token efficiency vs quality based on priority
- Reference Anthropic best practices from fetched docs

### Step 2: Secondary Review (prompt-pro B)

```
Task(subagent_type: "pro:prompt-pro")  # fallback: "general-purpose"
```

Pass Agent A's output + original prompt. Instruct:

- Identify SIGNIFICANT improvements only
- Filter out over-engineering
- If solid, return as-is
- Consider call frequency when evaluating token costs

### Step 3: Implementation (general-purpose C)

```
Task(subagent_type: "general-purpose")
```

Instruct:

- Read source file
- Apply approved changes
- Update documentation file if configured
- Warn about concurrent work (don't use git stash)

### Step 4: Verification (general-purpose D)

```
Task(subagent_type: "general-purpose")
```

Instruct:

- Verify changes match approved version
- Check for syntax errors (especially quote escaping in template literals)
- Fix any issues found

### Step 5: Commit (Coordinator Direct)

Coordinator commits directly (no subagent needed):

```bash
git add <modified-prompt-file> .prompt-review/
git commit -m "Improve <prompt-name> prompt

- <change-summary>

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Update review file with timestamp after commit.

## Common Issues

### Template Literal Quote Escaping

```typescript
// BAD
${cond ? "text with "quotes"" : "..."}

// GOOD
${cond ? 'text with "quotes"' : "..."}
```

### Token Cost Decisions

- **High-volume**: Prefer surgical improvements
- **Low-volume quality**: Accept higher token costs
- Secondary reviewer filters based on call frequency

## Coordinator Behavior

You are a coordinator. Goal: complete workflow with NO COMPACTION.

**Coordinator handles:**

- State detection (light file reads)
- Flow orchestration
- Committing changes
- Summarizing results

**Delegate to subagents:**

- Setup/interview (heavy user interaction)
- Review analysis (context-heavy)
- Implementation (code changes)
- Verification (code analysis)

Be conversational. Don't overwhelm users with options - guide them step by step.

## Supporting Files

Load only when needed (to preserve context budget):

- **[templates/review-template.md](templates/review-template.md)** - Load when creating new review files
- **[examples/sample-review.md](examples/sample-review.md)** - Load if user asks for example or format unclear
- **[examples/prompt-review.yaml](examples/prompt-review.yaml)** - Load when creating config
