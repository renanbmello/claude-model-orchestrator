#!/usr/bin/env bash
# Installs the model-orchestrator skill and helper subagents into ~/.claude
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.claude/skills" "$HOME/.claude/agents"
cp -R "$DIR/skills/model-orchestrator" "$HOME/.claude/skills/"
cp "$DIR"/agents/*.md "$HOME/.claude/agents/"
echo "Installed: ~/.claude/skills/model-orchestrator + agents (explore-haiku, log-reader, scoped-implementer)"
