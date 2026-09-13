# Verification without an eval harness

Load this only when the user asks to verify a change against real data instead of the repo's eval
harness. Every paid step needs the user's explicit yes and an estimate first.

## Inputs

- **Real inputs from the user's corpus.** Pull them with the repo's export tooling. Exports stay
  local, in gitignored paths or the run directory. No content goes into issues, commits, or PR text.
- **Supplements** fill categories the corpus lacks. Hand-pick them and mark every row with its
  source: `dev | prod | supplement`.
- **Cap over-represented categories** by marking the extra rows `excluded`. Don't delete them, so
  the selection can be audited.
- Write the input set as a file (TSV/JSONL) in the run directory, and record its path in `state.md`.

## Runner

- **Run it in the real runtime, not on the laptop.** Bot protection and WAFs fingerprint the client,
  so a local fetch sees different pages than the server does. Use a read-only server function (e.g. an
  internal action) that does the work and returns the result without writing anything.
- **Pin the baseline to a frozen copy of the pre-change code** (copy the old functions into the
  runner module at the base sha) so baseline and candidate run side by side in the same deployment.
  Build this in an early wave, before the change lands.
- **One action call per input,** driven by a local loop that appends one JSONL line per result and
  skips ids already in the file, so a crash or rate limit resumes where it stopped.
- Don't deploy to that deployment while the run is in progress.

## Judges

- **Fresh agents on the strongest model,** blind to which output is baseline and which is candidate,
  with the order randomised per item. Keep the unblinding key in a separate file the judges never see.
- **Split the items across several agents** to keep each one's context small and to spread judge bias.
- **One pass per dimension**, each a separate prompt:
  - output quality (pairwise preference with a rubric),
  - classification agreement (same label?),
  - span overlap (did both pick the same region of the source?).
- Judges write verdicts to files in the run directory. You compute the totals with a script, not
  by reading the verdicts yourself.

## Reporting

- **On the issue: totals only.** Counts, rates, latency percentiles, and spend. No per-item content.
- Put the method in one line (input count by source, judge model, passes), so the numbers can be
  reproduced.
- Put the actual spend in `state.md`.
