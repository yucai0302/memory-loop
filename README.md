<div align="center">

<img src="assets/banner.svg" alt="memory-loop" width="600" />

<br/>

[![Version](https://img.shields.io/badge/version-1.0.0-6366f1?style=flat-square&logo=semantic-release)](https://github.com/yucai0302/memory-loop/releases)
[![License](https://img.shields.io/badge/license-MIT-22c55e?style=flat-square)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v2.0+-f97316?style=flat-square&logo=anthropic)](https://code.claude.com)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL-64748b?style=flat-square)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-a855f7?style=flat-square)](https://github.com/yucai0302/memory-loop/pulls)

**[English](README.md) | [简体中文](README_CN.md)**

*The agent forgets. The repo doesn't.*

</div>

---

## Background

[Loop Engineering](https://addyosmani.com/blog/loop-engineering/) by Addy Osmani describes a shift in how we work with coding agents:

> *"You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents."*

A loop needs five building blocks — automations, worktrees, skills, connectors, and sub-agents — plus **one place to remember stuff**:

> *"A markdown file, or a Linear board, anything that lives outside the single conversation and holds what's done and what is next... the model forgets everything between runs so the memory has to be on disk and not in the context. The agent forgets, the repo doesn't."*

`memory-loop` is that sixth piece, built as a Claude Code plugin. Install it once, and every project you open gets a persistent, structured memory that loads automatically at session start and updates as you work.

---

## How it works

```
┌─────────────────────────────────────────────────────┐
│  Session starts                                     │
│    └── SessionStart hook fires automatically        │
│          ├── First time? Creates .claude/memory/    │
│          ├── Copies default schema.yaml             │
│          ├── Generates empty MEMORY.md              │
│          └── Injects memory content into context ──►│ Claude sees past decisions,
│                                                     │ goals, and gotchas instantly
│  Agent works ──────────────────────────────────────►│
│                                                     │
│  Task complete?                                     │
│    └── /memory-loop:save                           │
│          └── Agent reads schema → writes entries   │
│                                                     │
│  Session ends                                       │
│    └── Stop hook fires                              │
│          └── Warns if MEMORY.md needs compression  │
│                                                     │
│  Memory too large?                                  │
│    └── /memory-loop:compress                       │
│          └── Archives old entries → archive.md     │
└─────────────────────────────────────────────────────┘
```

### Files created in your project

```
your-project/
└── .claude/
    └── memory/
        ├── MEMORY.md      ← hot layer, injected every session
        ├── archive.md     ← cold layer, created on first compress
        └── schema.yaml    ← your customizable schema
```

> **Tip:** Commit these files to share memory with your team, or add `.claude/memory/` to `.gitignore` to keep them local.

---

## Installation

One command. Works across all your projects.

```bash
claude plugin install github:yucai0302/memory-loop
```

That's it. The plugin activates on the next Claude Code session.

### Scope options

| Command | Scope |
|---|---|
| `claude plugin install github:yucai0302/memory-loop` | All your projects (default) |
| `claude plugin install github:yucai0302/memory-loop --scope project` | This project only, committed to repo |
| `claude plugin install github:yucai0302/memory-loop --scope local` | This project only, gitignored |

---

## Quickstart: what happens after installation

### Step 1 — Open any project in Claude Code

The plugin fires automatically on session start. **No manual setup needed.**

```
[memory-loop] Initialized project memory at .claude/memory/MEMORY.md
[memory-loop] Edit .claude/memory/schema.yaml to customize tracked fields.

======= PROJECT MEMORY (memory-loop) =======
# Project Memory
## Project Context
_Not yet set..._
...
=============================================
[memory-loop] Memory loaded (312 chars). Update it with /memory-loop:save
```

### Step 2 — Work normally. When you finish a task, save.

```
/memory-loop:save
```

The agent reviews what happened in the session and writes structured entries:

```
Memory updated:
  + Completed: "Set up authentication middleware | JWT + Redis session"
  + Gotcha: "[auth] Token expiry not propagated to frontend → add 401 interceptor"
  - Active Goal: "Implement login flow" (marked done)
```

### Step 3 — Next session, memory is already there

Open the project again. The session start hook automatically injects everything the agent learned last time. No prompting needed.

### Step 4 — Check health, compress when needed

```bash
/memory-loop:status    # show file size and section counts
/memory-loop:compress  # archive old entries when memory grows large
```

---

## Customizing the schema

Edit `.claude/memory/schema.yaml` in your project. Changes take effect on the next session.

```yaml
version: "1.0"

hot_layer:
  sections:
    - name: "Project Context"
      description: "Project type, core tech stack, architecture overview."
      max_items: 1
      format: "prose"

    - name: "Active Goals"
      description: "Tasks currently in progress."
      max_items: 5
      format: "- [goal description] | started: YYYY-MM-DD"

    - name: "Decisions"
      description: "Key technical decisions."
      max_items: 10
      format: "- YYYY-MM-DD | chose X over Y | reason: Z"

    - name: "Gotchas"
      description: "Known bugs, traps, constraints the agent must respect."
      max_items: 20
      format: "- [module] problem → workaround / rule"

    - name: "Completed"
      description: "Recently finished tasks, rolling window."
      max_items: 10
      format: "- YYYY-MM-DD | task | outcome"

compression:
  trigger_chars: 8000       # warn when MEMORY.md exceeds this
  keep_recent_decisions: 5  # keep N newest on compress
  keep_recent_completed: 3  # keep N newest on compress
```

### Adding custom sections

Any section you add to `hot_layer.sections` is picked up automatically:

```yaml
    - name: "API Contracts"
      description: "External API endpoints this project depends on and their quirks."
      max_items: 15
      format: "- [service] endpoint | note"
```

---

## Commands reference

| Command | When to use |
|---|---|
| `/memory-loop:save` | After completing a task — writes session learnings to MEMORY.md |
| `/memory-loop:status` | Check file size, section health, compression recommendation |
| `/memory-loop:compress` | When warned about file size — archives old entries to archive.md |

You can also trigger saving naturally in conversation:
- *"Update the project memory"*
- *"Save what we did to memory"*
- *"Record this decision"*

---

## Why this design

**Why project-scoped and not global?**
Memory is specific to a codebase. Decisions and gotchas in project A are noise in project B.

**Why a markdown file and not a vector database?**
At the scale of a single project's working memory, full injection beats semantic retrieval. No retrieval gaps, no missed critical gotchas. When the file grows large, `/memory-loop:compress` archives old entries — the structured hot/cold split happens over time, not at write time.

**Why warn instead of auto-compress?**
Compression moves information. That should be a deliberate act, not something that silently drops context you might need.

**Why not write to CLAUDE.md?**
CLAUDE.md is for project conventions you write once. MEMORY.md is dynamic state that changes every session. Mixing them makes both harder to manage.

---

## Requirements

- Claude Code v2.0+
- bash (macOS / Linux / WSL)
- `yq` *(optional — for per-project compression thresholds)*

```bash
brew install yq   # macOS
snap install yq   # Linux
```

---

## Contributing

Issues and PRs welcome.

If you build a custom schema for a specific domain (chip design, data science, game dev, etc.), consider contributing it to `examples/` so others can start with something relevant.

---

## License

MIT © [yucai0302](https://github.com/yucai0302)
