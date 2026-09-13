# Issue body template

Create with `gh issue create --title "<imperative, specific>" --label <repo labels> --body-file <file>`.
Edit with `gh issue edit N --body-file <file>` when the plan changes. Don't pile on comments.
Never put user content from exports or production data in the body. Aggregates only.

```markdown
## Problem

{What the user experiences, in one paragraph. Where it happens in the code.}

## Baseline

| Metric                               | Value            | Source                       |
| ------------------------------------ | ---------------- | ---------------------------- |
| {e.g. linkSummary latency p50 / p90} | {6.5 s / 15.3 s} | {dev PostHog, 60 days, n=17} |

## Plan

### 1. {Stage name}

- [ ] {todo}: `{path}`
- [ ] {todo}: `{path}`

### 2. {Stage name}

- [ ] {todo}: `{path}`

### 3. Verification

- [ ] {how, on what inputs, what counts as success}

## Files

- `{path}`: {why}
- `{doc path}`: updated in the same commit as {stage}

## Rejected options

- **{Option}**: {why not, with the number or constraint that ruled it out}

## Sources

- {trace/query/dashboard link or command}
- {related issues and commits}
```

## Follow-up issue (filed mid-run)

```markdown
Found while working on #{PARENT}.

## What's wrong

{One paragraph, including the concrete failure scenario.}

## Files

- `{path}:{line}`

## Next step

{The concrete action. If there isn't one yet, don't file it.}
```

Apply the repo's labels (e.g. `followup` for "act when you touch this code"; `gated` needs a
checkable trigger in the body).
