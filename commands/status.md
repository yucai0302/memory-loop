---
description: "Show project memory status: file size, section counts, and whether compression is recommended."
---

Read `.claude/memory/MEMORY.md` and `.claude/memory/schema.yaml`, then report:

1. Current MEMORY.md character count vs compression threshold
2. Number of entries in each section vs max_items limits
3. Whether archive.md exists and how large it is
4. A recommendation: "Memory is healthy" or "Compression recommended — run /memory-loop:compress"

Keep the report concise, one line per section.
