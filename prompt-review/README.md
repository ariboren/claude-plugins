# prompt-review

A Claude Code skill for reviewing and improving LLM prompts using a multi-agent workflow.

## Features

- **Progressive setup** - Guides you through configuration based on current state
- **Interview-based review files** - Creates structured review documents from user input
- **5-step improvement pipeline** - Initial review → Secondary review → Implementation → Verification → Commit
- **Honest assessment** - Agents won't force changes on already high-quality prompts

## Installation

```bash
claude plugins add ariboren/claude-plugins/prompt-review
```

## Usage

```bash
/prompt-review                    # Start progressive flow
/prompt-review path/to/review.md  # Run pipeline on specific file
/prompt-review --reset            # Re-scan codebase, regenerate config
/prompt-review --new              # Force new review file creation
```

## How It Works

### Progressive Flow

The skill adapts based on your project's current state:

| State                  | Behavior                                               |
| ---------------------- | ------------------------------------------------------ |
| Fresh project          | "No setup found. Scan codebase or create review file?" |
| Has config, no reviews | "Found N prompts. Which to review?"                    |
| Has review files       | "Found these reviews. Run one or create new?"          |
| Given specific file    | Skip detection, run pipeline directly                  |

### The 5-Step Pipeline

1. **Initial Review (prompt-pro A)** - Analyzes prompt for weaknesses
2. **Secondary Review (prompt-pro B)** - Filters over-engineering, validates changes
3. **Implementation (Sonnet C)** - Applies approved changes to source
4. **Verification (Sonnet D)** - Checks for regressions and syntax errors
5. **Commit** - Creates atomic commit with descriptive message

### Configuration

The skill creates `.prompt-review.yaml` in your project root:

```yaml
prompt_patterns:
  - "**/*prompt*.ts"
  - "**/*prompt*.py"

reviews_dir: ".prompt-review"
documentation_file: null # optional
```

## Review File Format

Review files capture context for the AI reviewers:

```markdown
# Prompt Review: [Name]

## About This Prompt

[What it does and why it matters]

## Current Prompt

[The prompt text]

## Context

| Field          | Value       |
| -------------- | ----------- |
| Model          | gpt-4o-mini |
| Call frequency | High        |
| Priority       | Balanced    |

## Known Issues

[Problems you've noticed]

## Edge Cases

[Important scenarios to handle]
```

## License

MIT
