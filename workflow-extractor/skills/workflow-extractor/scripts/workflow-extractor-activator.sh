#!/bin/bash

# Workflow Extractor Skill Auto-Activation Hook
# This hook prompts Claude to evaluate whether a reusable workflow emerged during the session.
#
# Installation:
#   1. Copy this script to ~/.claude/hooks/
#   2. Make it executable: chmod +x ~/.claude/hooks/workflow-extractor-activator.sh
#   3. Add to ~/.claude/settings.json under hooks.UserPromptSubmit
#
# Note: This hook complements continuous-learning. They detect different things:
#   - continuous-learning: knowledge, debugging insights, gotchas
#   - workflow-extractor: processes, pipelines, multi-agent coordination

cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 WORKFLOW EXTRACTION EVALUATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

After completing this request, evaluate whether you executed
a multi-step workflow worth extracting as a reusable skill.

EVALUATE (all must be true):
- Did this involve 3+ coordinated steps with dependencies?
- Did a repeatable pattern emerge organically (not pre-defined)?
- Would this process apply to similar future contexts?
- Was the workflow validated and working well?

IF YES to ALL:
  Use Skill(workflow-extractor) to capture the workflow

SKIP if:
- Just standard coding/debugging → use continuous-learning instead
- Following existing documented procedures
- One-off context-specific operation
- Fewer than 3 coordinated steps

This is for PROCESSES (pipelines, coordination), not KNOWLEDGE (fixes, gotchas).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
