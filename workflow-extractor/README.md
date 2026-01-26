# Workflow Extractor

Automatically detect and extract reusable workflow skills from ad-hoc multi-step processes that emerge during Claude sessions.

## What It Does

While `continuous-learning` extracts **knowledge** (debugging insights, gotchas, fixes), `workflow-extractor` extracts **processes** (multi-step workflows, pipelines, multi-agent coordination patterns).

| continuous-learning             | workflow-extractor                  |
| ------------------------------- | ----------------------------------- |
| Extracts knowledge              | Extracts processes                  |
| "When X error, root cause is Y" | "To do X, run this 5-step pipeline" |
| Debugging insights, gotchas     | Multi-agent coordination, pipelines |
| Usually automatic               | Requires user confirmation          |

## When It Activates

A workflow is extractable when **all** of these apply:

1. **Multi-step (3+)**: Coordinated steps with dependencies
2. **Structure emerged**: Pattern developed organically, wasn't pre-defined
3. **Repeatable**: Would apply to similar contexts
4. **Validated**: Actually worked and produced quality output
5. **Non-trivial**: Not just "standard coding"

### Strong Signals

- Multi-agent coordination (3+ subagents with dependencies)
- Review/validation cycles (Agent A → Agent B reviews → Agent C implements)
- State/config files emerged during the session
- Same pattern applied to multiple items

### What Doesn't Qualify

- Implementing features step-by-step (just coding)
- Fixing multiple unrelated bugs (iteration, not workflow)
- Following existing documented procedures (already exists)
- One-off context-specific operations (not repeatable)

## Installation

### As a Plugin

The skill is available when the plugin is enabled. No additional setup required.

### Optional: Hook Activation

To get automatic prompts for workflow evaluation, add the hook to your settings:

```bash
# Copy the hook script
cp skills/workflow-extractor/scripts/workflow-extractor-activator.sh ~/.claude/hooks/

# Make executable
chmod +x ~/.claude/hooks/workflow-extractor-activator.sh
```

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "~/.claude/hooks/workflow-extractor-activator.sh"
      }
    ]
  }
}
```

## Usage

### Automatic (with hook)

After completing multi-step work, you'll see a prompt asking you to evaluate whether a workflow should be extracted.

### Manual

Invoke directly when you notice a reusable workflow pattern:

```
/workflow-extractor
```

Or tell Claude:

```
"This workflow worked well, let's save it as a skill"
"Extract this process as a reusable workflow"
```

## What Gets Extracted

Workflow skills follow a coordinator pattern:

```markdown
---
name: workflow-name
description: |
  What it does. Use when: (1) trigger, (2) trigger.
disable-model-invocation: true
---

# Workflow Name

## How It Works

### State Detection

[How to assess current state]

### Progressive Flow

[User journey based on state]

## The Pipeline

### Step 1: [Phase]

[What happens, which agent]

### Step N: [Phase]

[Continue for each phase]

## Coordinator Behavior

[How to orchestrate]
```

## Example

See [examples/extracted-workflow-example.md](skills/workflow-extractor/examples/extracted-workflow-example.md) for a complete example showing how `prompt-review` was extracted from an ad-hoc session.

## Relationship to continuous-learning

These skills complement each other. A single session might produce:

- A **knowledge skill** via continuous-learning (e.g., a debugging insight discovered)
- A **workflow skill** via workflow-extractor (e.g., the methodology used)

Use the right tool for the right extraction:

- **Knowledge**: errors, gotchas, workarounds, configurations → `continuous-learning`
- **Processes**: pipelines, review flows, multi-agent coordination → `workflow-extractor`
