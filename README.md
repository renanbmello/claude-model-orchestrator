# claude-model-orchestrator

A [Claude Code](https://claude.com/claude-code) skill that lets Claude orchestrate the Claude model lineup by itself: it picks **Haiku 5.5, Sonnet 5.5, Opus 5.5 or Fable 5.2** — and an effort level — for each slice of work before delegating, and puts subagents on cheaper models when a mistake is cheap to spot.

Based on Anthropic's guide [Which Claude model should you build with?](https://claude.dev/blog/which-claude-model-should-you-build-with/) (Nov 2026).

## What it does

- **Default to Opus 5.5 / medium**, move down to Sonnet for scoped work, Haiku for search/logs/classification, and up to Fable for migrations, architecture and deep research.
- **Effort before model**: raise effort one level first; past `high`, try the next model up at lower effort.
- **Explicit `model` on every subagent call**, so cheap work never inherits an expensive model.
- **Escalation ladder**: self-verification → +1 effort → next model up.
- Tells you the routing it chose (task → model/effort) so you can override it.

## Install

```bash
git clone https://github.com/renanbmello/claude-model-orchestrator
cd claude-model-orchestrator && ./install.sh
```

Or copy just the skill: `cp -R skills/model-orchestrator ~/.claude/skills/`.

### Included subagents (optional)

| Agent | Model | Use |
|---|---|---|
| `explore-haiku` | haiku | Cheap read-only code search |
| `log-reader` | haiku | Summarize failing tests from logs |
| `scoped-implementer` | sonnet | Well-scoped fixes against a clear spec |

Tip: set `CLAUDE_CODE_SUBAGENT_MODEL=sonnet` to change the default for subagents that don't specify a model.

## Usage

It triggers automatically when Claude is about to delegate or plan multi-agent work. You can also ask directly: *"orchestrate this across models"*, *"which model should handle this?"*, *"save quota on this task"*.

## Caveats

Prices and defaults are from the November 2026 guide and will drift. Measure on your own tasks — run a backlog task on two models with `/model` and compare `/usage`.

## License

MIT
