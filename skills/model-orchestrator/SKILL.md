---
name: model-orchestrator
description: Pick the right Claude model (Haiku 5.5, Sonnet 5.5, Opus 5.5, Fable 5.2) and effort level for each piece of work, and route subagents to cheaper models when a mistake is cheap to spot. Use whenever you are about to delegate to a subagent, split a task across workers, plan a multi-step or multi-agent job, or when the user asks which model/effort to use, wants to save cost or quota, or says "orchestrate", "route models", "auto mode", or "pick the model for me".
---

# Model Orchestrator

You are the lead. Before you delegate anything, decide **which model** and **which effort** each slice of work gets. Based on Anthropic's guide "Which Claude model should you build with?" (claude.dev, Nov 2026).

## The core rule

1. **Default: Opus 5.5 at medium.** Unsure? Start there.
2. **Turn effort before switching models.** Effort is the finer dial for cost and capability.
3. **Past `high`, try the next model up at a lower effort** instead of `xhigh`/`max` on the current one.
4. **Small models only where a mistake is cheap to spot** (searching, reading logs, running tests, summarizing, classifying). Code edits and judgment calls stay on the main model.
5. **Keep the expensive model's context lean.** Let cheap subagents do the verbose reading and hand back summaries.

## Routing table

| Task | Model | Starting effort | Why |
|---|---|---|---|
| Find files, grep, read logs, summarize docs, run tests and report | `haiku` (or `sonnet` if the read needs judgment) | default | Wrong answers are cheap to spot; the lead has the judgment calls |
| Classify, tag, route, extract at volume | `haiku` | medium | Lowest cost and latency |
| Chat / quick interactive replies | `sonnet` (`haiku` for simple volume) | low–medium | Fast |
| Well-scoped coding: bug fix, feature against a clear spec | `sonnet` | medium → high | Half Opus's token price |
| Everyday docs, slides, spreadsheets | `sonnet` | medium | Fast iteration, good design eye. Complex financial model or huge source pile → `opus` |
| Repeated agent tasks: investigation, review, drafting | `sonnet` | medium | Well-defined work rarely needs more |
| Everyday engineering, debugging, multi-PR features | `opus` | medium → high | Best cost/capability balance |
| Computer use, vision-heavy, long agentic loops | `opus` | medium | Built for long runs over many images |
| Major refactor/migration, architecture, leading many subagents | `fable` | medium → high | Most capable GA model for technical work |
| Deep research, scientific / quantitative analysis | `fable` | medium → high | Hardest technical projects |
| Long unattended runs, or Opus at high still falls short | `fable` | medium | Escalation target |

"Clear spec" does **not** automatically mean Sonnet: a migration or performance optimization can be fully specified and still need Opus (or Fable if major).

## How to apply it

### 1. Classify before you delegate
For each slice, ask: *If this subagent is wrong, will I notice cheaply?*
- **Yes** (search, logs, tests, summaries, extraction) → `haiku`/`sonnet`.
- **No** (edits that ship, design decisions, anything the user acts on directly) → keep on the lead's model or one at least as strong.

### 2. Set the model on the Agent call
Pass `model` explicitly on every Agent/Task call — never let it silently inherit an expensive model for cheap work:

```
Agent(description="Find auth call sites", subagent_type="Explore", model="haiku", prompt=...)
Agent(description="Fix null check in parser", model="sonnet", prompt=...)
Agent(description="Plan DB migration", model="fable", prompt=...)
```

This skill explicitly authorizes setting `effort` on delegated work when the routing table calls for something other than the default (e.g. `effort="high"` for a hard Sonnet fix). Leave it unset when the default fits.

Note: the built-in Explore subagent now runs on the session's model. For cheap exploration, pass `model="haiku"` or install the `explore-haiku` agent from this repo.

### 3. Escalate in this order when output isn't good enough
1. Give the worker a way to **verify its own work** (a test, a build, a script hitting the endpoint). Often cheaper than more effort.
2. **Raise effort one level.**
3. **Move one model up**, starting at a *lower* effort than you used on the smaller one.

If outcomes are automatically checkable, run everything at low effort and re-run only the failures at high.

### 4. Bulk work bigger than one context
Lead (Opus/Fable) splits → many `sonnet` workers in parallel → lead merges. Skip this for a single chain of dependent steps or work that fits one context; planning + merging then costs more than it saves.

### 5. Switching the main session's model
- Switch at a natural break: `/compact` first, or start fresh with a short written plan — the new model pays cache-write on the whole history.
- Moving **down** a tier loses earlier thinking blocks; moving away from Fable 5.2 always does. Write the plan down before switching.

## Quick reference

| | Haiku 5.5 | Sonnet 5.5 | Opus 5.5 | Fable 5.2 |
|---|---|---|---|---|
| In / out per 1M | $0.10 / $0.50 (≤100K prompt) · $0.50 / $2.50 (>100K) | $2 / $10 | $4 / $20 | $8 / $40 |
| Cache read per 1M | $0.01 / $0.05 | $0.10 | $0.20 | $0.20 |
| Latency | Fastest | Fast | Moderate | Moderate |
| Default effort (Claude Code) | medium | medium | medium | medium |

Haiku is cheapest on **short** prompts; on long prompts compare cost per finished task with Sonnet, not list price.

## Before you report back
Briefly state the routing you chose (one line per slice: task → model/effort), so the user can see and override it.
