# Quality gate prompts

Every agent here is **fresh**, launched with `Agent`, never resumed with `SendMessage`. A resumed
reviewer grades its own findings. Scope is always an exact range or an explicit sha list, never
`HEAD~n`, because other sessions may commit to the same branch.

Tiers (`~/.claude/model-policy.md`): simplify `sonnet`; review `opus`, or `fable` when the policy
scores it 3+ (e.g. a broad range over auth, concurrency, or payments) or when a `fable` agent wrote
the code; fix review `opus`, or `fable` when the fixes are to fable-authored code.

## Simplify (step 1)

```
Fresh simplify pass on {ISSUE_REFS}. Read the shared brief at {RUN_DIR}/brief.md. Its working
rules are binding, except that you may edit any file the range below changed.

Scope: exactly `git diff {BASE_SHA}..{HEAD_SHA}` ({or: only these commits: sha, sha, sha}).
Don't touch any file or line outside it.

Invoke the `simplify` skill on that scope. Preserve behavior exactly, with no new abstractions and
no scope creep. Run the brief's checks, then commit your cleanups with scoped `git add` and the
brief's footer.

State explicitly: `BEHAVIOR_NEUTRAL: yes|no`, and list your commit shas.

Output contract: ≤250 words. Sections: `RESULT`, `DETAIL`, `BLOCKED`.
```

When a simplify commit changes more than ~50 lines, tell the reviewer (below) to diff that commit
on its own and verify the behavior-neutral claim.

## Review (step 2)

```
Fresh local review of {ISSUE_REFS}. You did not write any of this code.

Scope: exactly `git diff {BASE_SHA}..{HEAD_SHA}` ({or: these commits: sha, sha}), which includes
simplify commits {SIMPLIFY_SHAS}. The code is on disk. Don't fetch, check out, or modify
anything, and don't commit.

{Include when Model = fable: "You are on the strongest tier. Delegate searches, summaries and
mechanical edits to `sonnet` subagents (paths, not contents); reason yourself on the judgment this
task exists for, and read in full anything you are judging."}

ABSOLUTE: local only. No `gh pr comment`, `gh pr review`, or `gh issue comment`. Post nothing.

Read first: the spec (`gh issue view {ISSUE_NUMBER}`), {RUN_DIR}/brief.md for repo conventions,
and the "## Resolved" / "## Won't fix" sections of {RUN_DIR}/state.md. Don't re-raise those.

Hunt for: logic bugs, unhandled errors, concurrency and lifetime problems, broken invariants,
divergence from the issue's spec, and violations of the repo's CLAUDE.md rules. Where the diff
changes a symbol's signature or behavior, read its direct callers and callees, one hop only.
{If a simplify commit is large: "Commit {SHA} claims to be behavior-neutral. Diff it alone and
verify; any behavior change in it is at least MAJOR."}

Report only what you would defend to a senior engineer. Skip what a linter, compiler, or CI
catches, pre-existing issues, untouched lines, and nitpicks.

Label each finding BLOCKING (wrong behavior, security, breaks a contract), MAJOR (real edge-case
bug, missing error handling, unplanned divergence from spec), or MINOR (polish; never blocks).
Append to {RUN_DIR}/state.md under "## Review — pass {N}", one line each:
`SEVERITY | file:line | issue | owner: ?`. The foreman fills in the owner.

End with exactly one line: `VERDICT: CLEAN` or `VERDICT: NEEDS_WORK`.

Output contract: ≤250 words. Sections: `RESULT`, `DETAIL`, `BLOCKED`.
```

## Fix review (step 4)

Same prompt as Review, from a **new** agent, with these changes:

- Scope becomes `git show {FIX_SHAS}` (the fix commits only), pass number N+1.
- Add: "Check that each row under '## Resolved' is actually fixed by its sha, and that the fixes
  introduced nothing new. Don't review code outside those commits."
