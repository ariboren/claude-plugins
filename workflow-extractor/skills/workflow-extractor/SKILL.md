---
name: workflow-extractor
description: |
  Extract reusable workflow skills from ad-hoc multi-step processes. Use when: (1) a multi-step
  process emerged organically and worked well, (2) you coordinated 3+ steps with dependencies,
  (3) a review/validation cycle was executed, (4) user says "save this workflow" or "this process
  worked well." Captures automatable pipelines and coordination patterns as new skills, distinct
  from knowledge extraction.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
  - TodoWrite
---

# Workflow Extractor

You extract reusable workflow skills from ad-hoc multi-step processes that emerge during sessions.
This is distinct from knowledge extraction (debugging insights, gotchas)—you capture **processes**
that can be automated and repeated.

## Core Distinction

| continuous-learning             | workflow-extractor                  |
| ------------------------------- | ----------------------------------- |
| Extracts **knowledge**          | Extracts **processes**              |
| "When X error, root cause is Y" | "To do X, run this 5-step pipeline" |
| Debugging insights, gotchas     | Multi-agent coordination, pipelines |
| 50-150 lines typical            | 150-400 lines typical               |
| Usually automatic               | Usually requires user confirmation  |

## Detection Criteria

A workflow is extractable when **ALL** of these apply:

### Required Criteria

1. **Multi-step (3+)**: Coordinated steps with dependencies, not just sequential tasks
2. **Structure emerged**: Pattern developed organically during the session, wasn't pre-defined
3. **Repeatable**: Would apply to similar contexts (other files, projects, domains)
4. **Validated**: Actually worked and produced quality output
5. **Non-trivial**: Not just "standard coding" or "basic debugging"

### Strong Signals

- **Multi-agent coordination**: 3+ subagents launched with dependencies between them
- **Review/validation cycle**: Agent A produces → Agent B reviews → Agent C implements
- **State/config emerged**: Created config files, review files, intermediate artifacts
- **Pattern repetition**: Same process applied to multiple items in the session
- **User satisfaction**: Explicit positive feedback about the process

### Anti-patterns (Don't Extract)

| Pattern                                  | Why not a workflow                 |
| ---------------------------------------- | ---------------------------------- |
| Implementing a feature step-by-step      | Just coding, no reusable process   |
| Fixing multiple unrelated bugs           | Iteration, not a coherent workflow |
| Following existing documented procedures | Already exists, don't duplicate    |
| One-off context-specific operation       | Not repeatable                     |
| Single-step automation                   | Too simple, not a workflow         |

## Selectivity Guidelines

Most sessions don't produce extractable workflows. Be highly selective:

1. **"Would I want this as a `/command`?"** - If it doesn't feel like a command, skip it
2. **"Would someone else benefit from this?"** - Personal preferences don't qualify
3. **"Is this process, not just steps?"** - Workflows have phases and decision points
4. **"Did structure emerge, or was I just following instructions?"** - Pre-defined procedures don't count

**When uncertain, don't extract.** False negatives are cheap (you can always extract later); false positives create skill bloat and maintenance burden.

## Extraction Process

### Step 1: Recognize the Workflow

Analyze the session for workflow patterns:

```
Questions to answer:
- What were the distinct phases?
- What was the input/output of each phase?
- What tools/agents were used at each step?
- What decisions or branching occurred?
- What made this more than just "doing work"?
```

### Step 2: Abstract from Specifics

Generalize the workflow:

- Replace specific file names with patterns or placeholders
- Identify general trigger conditions
- Determine what configuration is needed
- Extract the reusable structure

### Step 3: Validate Extraction Criteria

Verify all criteria are met:

- [ ] Multi-step (3+ coordinated steps)
- [ ] Structure emerged organically
- [ ] Repeatable in similar contexts
- [ ] Validated (actually worked)
- [ ] Non-trivial (not standard practice)

If any criterion fails, **do not extract**.

### Step 4: Get User Confirmation

Before creating the skill, present:

1. Proposed skill name and description
2. Summary of the workflow phases
3. Where it would be saved
4. Ask if they want to proceed

Use AskUserQuestion:

```
"I noticed a reusable workflow pattern in this session:

**Proposed skill:** `[name]`
**Purpose:** [1-2 sentences]
**Phases:** [list key phases]

Would you like me to extract this as a reusable skill?"
```

### Step 5: Structure the Skill

Create a skill following this template:

```markdown
---
name: [workflow-name]
description: |
  [Action verb] [what it does]. Use when: (1) [trigger 1], (2) [trigger 2].
  Guides you through [key phases]. [Any important context.]
disable-model-invocation: true
---

# [Workflow Name]

[1-2 sentence description of what this workflow accomplishes]

## How It Works

### State Detection

[How to assess current state when invoked]

### Progressive Flow

[Flowchart or description of user journey based on state]

## Configuration

[What config file(s) to create, if any. Include schema.]

## The Pipeline

### Step 1: [Phase Name]

[What happens, which agent/tool, input/output expectations]

### Step N: [Phase Name]

[Continue for each phase]

## Coordinator Behavior

- Assess state, guide user through appropriate flow
- Delegate to subagents where appropriate
- Handle errors by restarting failed steps
- Provide summary after completion
```

### Step 6: Save the Skill

Save to appropriate location:

- **Project-specific**: `.claude/skills/[skill-name]/SKILL.md`
- **User-wide**: `~/.claude/skills/[skill-name]/SKILL.md`

Create supporting files if needed:

- `templates/` for templates Claude fills in
- `examples/` for reference examples
- `scripts/` for executable helpers

## Quality Gates

Before finalizing:

- [ ] Description contains specific trigger conditions
- [ ] Workflow has been validated (actually worked in this session)
- [ ] Steps are specific enough to be actionable
- [ ] Steps are general enough to be reusable
- [ ] No sensitive information included
- [ ] Doesn't duplicate existing skills or documentation
- [ ] `disable-model-invocation: true` set—workflows coordinate complex multi-step operations; automatic invocation risks unintended side effects and should be user-triggered
- [ ] Dependencies documented—if the workflow requires specific tools, agents, or other skills, note them in the skill

## Example: Extraction Flow

**Scenario**: During a session, you helped the user review and improve an LLM prompt through:

1. Interview about the prompt's purpose and context
2. Create a structured review file with metadata
3. Launch prompt-pro agent for initial review
4. Launch second prompt-pro for validation/filtering
5. Launch general-purpose to implement approved changes
6. Launch general-purpose to verify changes
7. Commit with descriptive message

**Recognition**:

- Multi-step: 7 coordinated phases ✓
- Structure emerged: Review file format, dual-review pattern ✓
- Repeatable: Applies to any prompt in any project ✓
- Validated: Produced improved prompts ✓
- Non-trivial: Novel coordination pattern ✓

**Extraction**: → `prompt-review` skill with:

- State detection (config exists? review files exist?)
- Progressive flow based on state
- Interview questions for new reviews
- 5-step agent pipeline
- Coordinator behavior guidelines

## Integration Notes

### Relationship to continuous-learning

These skills complement each other:

- A session might produce **both** a knowledge skill (debugging insight discovered) **and** a workflow skill (the methodology used to discover it)
- Use continuous-learning for: errors, gotchas, workarounds, configurations
- Use workflow-extractor for: pipelines, review processes, multi-agent coordination

### When Invoked Explicitly

If user says `/workflow-extractor` or "save this workflow":

1. Analyze the current session for workflow patterns
2. Present what you found (or explain why nothing qualifies)
3. If a workflow exists, proceed with extraction after confirmation

### Updating Existing Workflows

If a later session improves an already-extracted workflow:

1. **Check for existing skill**: Search `~/.claude/skills/` and `.claude/skills/` for related workflows
2. **Decide: update or new**: Is this an improvement to the same workflow, or a distinct variant?
3. **If updating**: Edit the existing SKILL.md, bump version, document changes in a changelog comment
4. **If new variant**: Create a new skill with a distinct name (e.g., `prompt-review-lite`)

Prefer updating over proliferating similar workflows.

### Self-Check Prompts

After completing multi-step work, ask yourself:

- "Did I just coordinate a novel process that could be reused?"
- "Would this be valuable as a `/command` for similar future tasks?"
- "Did structure emerge organically, or was I following existing patterns?"

If yes to all, consider workflow extraction.
