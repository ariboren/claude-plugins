# Ari's Claude Code Plugins

A marketplace of Claude Code plugins by Ari Borensztein.

## Installation

Add this marketplace to Claude Code:

```
/plugin marketplace add ariboren/claude-plugins
```

## Available Plugins

### linear-claude-session-tracking

Automatically track Claude Code sessions in Linear with commits and file changes.

**Install:**

```
/plugin install linear-claude-session-tracking@ariboren
```

**Features:**

- Creates Linear issues for each Claude Code session
- Tracks git commits with file changes
- Supports session resume
- Configurable team, project, and label

### plan-loop

Coordinate subagent loop to create comprehensive implementation plans with iterative review.

**Install:**

```
/plugin install plan-loop@ariboren
```

**Features:**

- Structured requirements interview with users
- Delegates all work to specialized subagents (coordinator pattern)
- Multiple review iterations until plan is complete
- Auto-generates plan files with architecture, implementation steps, and edge cases
- Commits plans to git automatically

**Usage:**

```
/plan-loop [optional-plan-file-path]
```

## License

MIT
