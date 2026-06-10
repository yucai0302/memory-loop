---
name: memory-loop
description: "Update project memory after completing a task, making a key decision, discovering a gotcha, or changing active goals. Use this skill at the end of any meaningful unit of work to write structured entries into .claude/memory/MEMORY.md following the project schema. Also use when the user asks to save memory, update memory, or record what was done."
---

# memory-loop — Write Protocol

You are writing structured entries into `.claude/memory/MEMORY.md`.
This file is the project's persistent memory. It survives between sessions.
Write accurately and concisely. Future agents (and you in a future session) will rely on this.

## Step 1 — Read the current schema

Read `.claude/memory/schema.yaml` to understand which sections exist, their format strings, and their `max_items` limits.

## Step 2 — Read the current MEMORY.md

Read `.claude/memory/MEMORY.md` to see what is already there.

## Step 3 — Determine what needs updating

Based on what just happened in this session, identify which sections need new entries:

| Trigger | Section to update |
|---|---|
| Task finished | **Completed** (add entry) + **Active Goals** (remove the done goal) |
| Technical decision made | **Decisions** (add entry) |
| Bug / constraint / trap discovered | **Gotchas** (add entry) |
| New work started | **Active Goals** (add entry) |
| Project overview changed | **Project Context** (rewrite) |

Only update sections that are actually affected. Do not rewrite unchanged sections.

## Step 4 — Apply format and max_items rules

- Use the exact format string from the schema for each section.
- After adding a new entry, if the section now has more than `max_items` entries, remove the oldest one(s) to stay within the limit.
- Never delete **Decisions** or **Gotchas** entries during a regular write — those are only pruned during compression.

## Step 5 — Write the file

Write the updated MEMORY.md back to disk.
Preserve the file header comment block at the top.
Do not change sections you did not touch.

## Step 6 — Confirm

Report briefly what you wrote:
> "Memory updated: added 1 Completed entry, removed Active Goal 'X'."

---

## Format reference (defaults — actual values come from schema.yaml)

```
## Active Goals
- [goal description] | started: YYYY-MM-DD

## Decisions
- YYYY-MM-DD | chose X over Y | reason: Z

## Gotchas
- [module] problem description → workaround / rule

## Completed
- YYYY-MM-DD | task description | outcome
```
