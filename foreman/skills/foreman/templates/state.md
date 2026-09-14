# {slug}

repo: {path} branch: {default} base: {sha} issues: #{N}, #{M}
brief: {RUN_DIR}/brief.md watcher: none | {pid cmd} → {user decision}
off-limits: {pre-existing dirty paths, or "none"} spend cap: ${cap}/agent

## Waves

| Wave | Work            | Agent (name / id) | Model                         | Owns     | Depends on | Status                       |
| ---- | --------------- | ----------------- | ----------------------------- | -------- | ---------- | ---------------------------- |
| 0    | {config change} | {name / id}       | {tier} ({axes}) [redo: {why}] | `{path}` | none       | planning / approved / landed |

## Landed

- {sha} {subject} ({agent}, wave {n})

## Deploys

- {sha} → {target} ({date time})

## Spend

- {agent}: est ${x} → actual ${y}

## Follow-ups filed

- #{N} {title}

## Review — pass 1 (range {base}..{head})

- SEVERITY | file:line | issue | owner: {agent}

## Resolved

- {issue} → {sha}

## Won't fix

- {issue} → {reason} # reviewers must not re-raise these

## Notes

- {decisions the user made mid-run that change how you coordinate; one line each}
