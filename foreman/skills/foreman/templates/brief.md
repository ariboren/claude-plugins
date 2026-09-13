# Shared brief: {ISSUE_REFS} ({TOPIC})

Read the issue first: `gh issue view {ISSUE_NUMBER}`. It is the spec. This brief adds session
context and the working rules every implementer follows. Your coordinator is the foreman session
(`SendMessage` to `main`).

## Why this work exists

{2–5 sentences: the user-visible problem, where it shows up in the code, and the measured baseline
with its source, e.g. "dev PostHog, 60 days, n=17: p50 6.5 s / p90 15.3 s".}

## What already landed (read these diffs)

- `{sha}` {subject}: {one line on what it changed and why it matters to you}
- {skills or docs written this session that explain a non-obvious constraint}

## Key files

- `{path}`: {what lives there}
- `{doc path}`: must be updated in the same commit when {condition}

## Repo parameters

| Parameter        | Value                                                      |
| ---------------- | ---------------------------------------------------------- |
| Branch           | `{DEFAULT_BRANCH}`                                         |
| Typecheck        | `{TYPECHECK_CMD}`                                          |
| Lint (scoped)    | `{LINT_CMD} <your files>`                                  |
| Tests            | `{TEST_CMD}`                                               |
| Format (scoped)  | `{FORMAT_CMD} <your files>`                                |
| Commit footer    | `{MAGIC_WORD} #{ISSUE_NUMBER}` then `{TRAILER}`            |
| Deploys          | foreman only; target `{DEPLOY_TARGET}`                     |
| Spend cap        | ${SPEND_CAP} per agent, authorised only for {SCOPE}        |
| Off-limits paths | {uncommitted files that belong to someone else, or "none"} |

## Working rules (non-negotiable)

1. **Plan first, then stop.** Your first reply is a quick plan: files you will touch, the approach,
   tests, open questions. Keep it concise. Do not edit any file until the foreman replies with sign-off.
   Reading code and running read-only commands is fine while planning.
2. **Shared checkout, on `{DEFAULT_BRANCH}`.** Other agents work in the same working tree at the
   same time.
   - Touch only the files your approved plan names. If you need another file, say so and wait.
   - Commit only your own files (`git add <paths>` or `git commit -- <paths>`, never `git add -A`/`.`).
     Verify the branch in the same command:
     `[ "$(git branch --show-current)" = {DEFAULT_BRANCH} ] && git add <paths> && git commit -m ...`.
   - Never stash, reset, checkout, or revert anything. If the tree has changes that aren't yours,
     leave them alone.
   - Shared docs: edit right before committing, commit at once, and check `git status <doc>` for
     someone else's pending edit first.
   - Generated files: commit only your own hunks (`git apply --cached` with a trimmed patch).
   - Commit messages: imperative summary, bullet body, the footer from the table above.
3. **No deploys.** Do not run `{DEPLOY_CMD}` or any watcher that pushes on save. When you need your
   code deployed, message the foreman and wait. Read-only commands against the deployment (`run` a
   read-only function, logs, data) are fine once your code is live.
4. **No secrets printed.** Check that an env var exists by name only (`… | cut -d= -f1`).
5. **Money:** no eval harness and no paid runs outside {SCOPE}. Before any real LLM or paid-API
   call, state an estimate. Stop and ask if it exceeds ${SPEND_CAP}.
6. **Permission denied or blocked:** stop and report it to the foreman. Don't work around it.
7. **Before committing:** typecheck, scoped lint, the relevant tests, scoped format. Hooks must
   pass. Never `--no-verify`. If a hook fails on another agent's file, tell the foreman.
8. **Code style:** {repo style: indentation, exports, async style, strictness, copy casing, comment
   density, and required reading such as framework guideline files}.
9. **Tooling gotchas:**
   - {e.g. run vitest/eslint from the repo root}
   - {e.g. a lint hook blocks the Edit tool on some files, so edit those with a script}
   - {e.g. prettier reflows markdown tables, so assert the replacement count on doc edits}
   - `timeout` isn't installed on macOS; `git add -p` is interactive.
10. **Final report:** commit hashes, what you verified and how, anything left undone and why, and
    notes for later waves (interfaces you exposed, constraints you found).
