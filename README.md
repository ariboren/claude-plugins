# Ari's Claude Code Plugins

A marketplace of Claude Code plugins by Ari Borensztein.

## Installation

Add this marketplace to Claude Code:

```
/plugin marketplace add ariboren/claude-plugins
```

Then install individual plugins as needed.

---

## Plugins

### implement

Execute multi-session implementations with stacked PRs and an automated agent pipeline.

```
/plugin install implement@ariboren
```

**Usage:**

```
/implement <session-plan-path>
```

**Pipeline (5 steps per session):**

1. **Implementation** - General-purpose agent implements the session plan
2. **Create draft PR** - Pushes branch and creates draft PR immediately
3. **Simplify** - Uses `code-simplifier@anthropic` agent (optional)
4. **Review** - Uses `/code-review@anthropic` skill, or falls back to manual review
5. **Fixup** - Addresses review issues (if any), max 3 cycles
6. **Documentation** - Updates CLAUDE.md and relevant docs
7. **Mark PR ready** - Finalizes the PR

**Git workflow:** Stacked PRs - each session branches off the previous, enabling incremental review.

**Optional dependencies:**

```
/plugin install code-simplifier@anthropic
/plugin install code-review@anthropic
```

---

### plan-loop

Coordinate a subagent loop to create comprehensive implementation plans with iterative review.

```
/plugin install plan-loop@ariboren
```

**Usage:**

```
/plan-loop [plan-file-path]
```

**Phases:**

1. **Objective** - Get brief description from user
2. **Requirements interview** - Subagent conducts thorough interview (scope, edge cases, constraints, success criteria)
3. **Create plan** - Plan subagent writes initial implementation plan
4. **Review loop** - Critical reviewers iterate until ZERO issues found (4-8+ iterations typical)
5. **Summary** - Final summary of the plan

**Features:**

- Coordinator pattern - delegates ALL work to subagents for fresh context
- Ruthless review criteria - plan must achieve full consensus
- Auto-commits plan to git
- Handles user questions mid-loop

---

### linear-claude-session-tracking

Automatically track Claude Code sessions in Linear with commits and file changes.

```
/plugin install linear-claude-session-tracking@ariboren
```

**Setup:**

```
/setup
```

Requires `linear` CLI installed and authenticated (`linear auth login`).

**Features:**

- Creates Linear issues for each Claude Code session
- Tracks git commits with file changes
- Supports session resume
- Configurable team, project, and label

**Config:** `~/.config/linear-claude-session-tracking/config`

```
LINEAR_TEAM="TEAM"
LINEAR_PROJECT="Claude sessions"
LINEAR_LABEL="claude"
```

---

### pro

Professional specialized agents for domain-specific tasks.

```
/plugin install pro@ariboren
```

**Available agents** (use via Task tool with `subagent_type: "pro:agent-name"`):

| Agent                     | Description                                       |
| ------------------------- | ------------------------------------------------- |
| `pro:a11y-pro`            | Accessibility testing, WCAG compliance            |
| `pro:api-dev`             | API architecture, REST/GraphQL design             |
| `pro:backend-dev`         | Scalable APIs, microservices                      |
| `pro:game-pro`            | Game engine programming, graphics optimization    |
| `pro:javascript-pro`      | Modern ES2023+, Node.js, async patterns           |
| `pro:mobile-pro`          | Native and cross-platform iOS/Android             |
| `pro:pen-tester`          | Penetration testing, vulnerability assessment     |
| `pro:react-native-pro`    | React Native optimization, Hermes, native modules |
| `pro:react-pro`           | React 18+, hooks, server components               |
| `pro:refactoring-pro`     | Safe code transformation, design patterns         |
| `pro:root-cause-analyzer` | Bug investigation, debugging                      |
| `pro:security-auditor`    | Security assessments, compliance validation       |
| `pro:security-engineer`   | DevSecOps, cloud security                         |
| `pro:seo-pro`             | Technical SEO, content optimization               |
| `pro:sql-pro`             | Query optimization, database design               |
| `pro:swift-pro`           | Swift 5.9+, SwiftUI, async/await                  |
| `pro:typescript-pro`      | Advanced types, full-stack TS                     |
| `pro:ui-designer`         | Visual design, design systems, accessibility      |

---

## License

MIT
