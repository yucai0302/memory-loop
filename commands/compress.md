---
description: "Compress project memory. Archives older entries from MEMORY.md into archive.md to keep the hot layer lean. Run when memory-loop warns about file size."
---

Invoke the `memory-compressor` agent to compress `.claude/memory/MEMORY.md`.

The agent will:
1. Read the current memory and schema compression settings
2. Move older Decisions and Completed entries to `.claude/memory/archive.md`
3. Rewrite MEMORY.md keeping only recent high-value entries
4. Report what was archived
