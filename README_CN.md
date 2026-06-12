<div align="center">

<img src="assets/banner.svg" alt="memory-loop" width="600" />

<br/>

[![Version](https://img.shields.io/badge/版本-1.0.0-6366f1?style=flat-square)](https://github.com/yucai0302/memory-loop/releases)
[![License](https://img.shields.io/badge/许可证-MIT-22c55e?style=flat-square)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v2.0+-f97316?style=flat-square&logo=anthropic)](https://code.claude.com)
[![Platform](https://img.shields.io/badge/平台-macOS%20%7C%20Linux%20%7C%20WSL-64748b?style=flat-square)]()
[![PRs Welcome](https://img.shields.io/badge/PR-欢迎贡献-a855f7?style=flat-square)](https://github.com/yucai0302/memory-loop/pulls)

**[English](README.md) | [简体中文](README_CN.md)**

*Agent 会遗忘，代码仓库不会。*

</div>

---

## 安装

在 Claude Code 中执行以下两条命令：

```bash
/plugin marketplace add yucai0302/memory-loop
/plugin install memory-loop@memory-loop
```

选择 **Install for you (user scope)**，重启 CC 即可。

---

## 背景

Addy Osmani 在 [Loop Engineering](https://addyosmani.com/blog/loop-engineering/) 中提出了一种与 AI 编程 Agent 协作的新范式：

> *"你不应该再手动给 Agent 写 Prompt 了，你应该设计驱动 Agent 的 Loop 系统。"*

一个完整的 Loop 需要五个模块——自动化触发、工作树、技能、连接器、子 Agent——加上**一个存储状态的地方**：

> *"一个 Markdown 文件，或一个 Linear 看板，任何能在单次对话之外保存'做了什么'和'下一步是什么'的东西……模型在两次 run 之间会忘掉所有内容，所以记忆必须在磁盘上，而不是在 context 里。Agent 会遗忘，代码仓库不会。"*

`memory-loop` 就是这第六个模块，以 Claude Code Plugin 的形式实现。**安装一次，每个项目自动获得结构化记忆**，在 session 启动时自动加载，在工作过程中持续更新。

---

## 工作原理

```
┌─────────────────────────────────────────────────────┐
│  Session 启动                                        │
│    └── SessionStart Hook 自动触发                    │
│          ├── 首次使用？自动创建 .claude/memory/      │
│          ├── 复制默认 schema.yaml                    │
│          ├── 生成空的 MEMORY.md                      │
│          └── 将记忆内容注入 context ───────────────►│ Claude 立即获知
│                                                     │ 过往决策、目标和已知坑
│  正常工作 ──────────────────────────────────────────►│
│                                                     │
│  任务完成？                                          │
│    └── /memory-loop:save                           │
│          └── Agent 读取 schema → 结构化写入         │
│                                                     │
│  Session 结束                                        │
│    └── Stop Hook 自动触发                            │
│          └── 文件过大时给出压缩提示                  │
│                                                     │
│  记忆过大？                                          │
│    └── /memory-loop:compress                       │
│          └── 归档旧条目 → archive.md               │
└─────────────────────────────────────────────────────┘
```

### 在你的项目中创建的文件

```
your-project/
└── .claude/
    └── memory/
        ├── MEMORY.md      ← 热层，每次 session 自动注入
        ├── archive.md     ← 冷层，首次压缩时创建
        └── schema.yaml    ← 可自定义的记忆结构
```

> **提示：** 将这些文件提交到 Git 可与团队共享记忆；加入 `.gitignore` 则保持本地私有。

---

## 安装

一条命令，适用于你所有的项目。

```bash
claude plugin install github:yucai0302/memory-loop
```

安装后，下一次打开 Claude Code 即自动生效。

### 安装范围选项

| 命令 | 范围 |
|---|---|
| `claude plugin install github:yucai0302/memory-loop` | 所有项目（默认） |
| `claude plugin install github:yucai0302/memory-loop --scope project` | 仅当前项目，提交到仓库 |
| `claude plugin install github:yucai0302/memory-loop --scope local` | 仅当前项目，不提交 |

---

## 快速上手：安装后如何使用

### 第一步 — 用 Claude Code 打开任意项目

Plugin 在 Session 启动时自动触发，**无需任何手动配置**。

```
[memory-loop] 已初始化项目记忆：.claude/memory/MEMORY.md
[memory-loop] 可编辑 .claude/memory/schema.yaml 自定义记录字段。

======= PROJECT MEMORY (memory-loop) =======
# Project Memory
## Project Context
_尚未设置..._
...
=============================================
[memory-loop] 记忆已加载（312 字符）。用 /memory-loop:save 更新记忆
```

### 第二步 — 正常工作，任务完成后保存

```
/memory-loop:save
```

Agent 会回顾本次 session 发生了什么，并写入结构化条目：

```
记忆已更新：
  + Completed: "完成认证中间件 | JWT + Redis session"
  + Gotcha: "[auth] Token 过期未传递到前端 → 需加 401 拦截器"
  - Active Goal: "实现登录流程"（已完成，移除）
```

你也可以用自然语言触发：
- *"更新项目记忆"*
- *"把我们做的内容保存到记忆里"*
- *"记录一下这个决策"*

### 第三步 — 下次 Session，记忆已就位

再次打开项目，SessionStart Hook 自动将上次所有学习成果注入 context。无需任何操作。

### 第四步 — 检查状态，按需压缩

```bash
/memory-loop:status    # 查看文件大小和各分区条目数
/memory-loop:compress  # 记忆过大时，归档旧条目
```

---

## 自定义 Schema

编辑项目中的 `.claude/memory/schema.yaml`，下次 Session 启动时生效。

```yaml
version: "1.0"

hot_layer:
  sections:
    - name: "Project Context"
      description: "项目类型、核心技术栈、架构概述。"
      max_items: 1
      format: "prose"

    - name: "Active Goals"
      description: "当前进行中的任务目标。"
      max_items: 5
      format: "- [目标描述] | 开始: YYYY-MM-DD"

    - name: "Decisions"
      description: "已做出的关键技术决策。"
      max_items: 10
      format: "- YYYY-MM-DD | 选择了 X 而非 Y | 原因: Z"

    - name: "Gotchas"
      description: "已知的坑、约束和必须遵守的规则。"
      max_items: 20
      format: "- [模块] 问题描述 → 规避方式 / 规则"

    - name: "Completed"
      description: "最近完成的任务，滚动保留。"
      max_items: 10
      format: "- YYYY-MM-DD | 任务描述 | 产出结果"

compression:
  trigger_chars: 8000       # MEMORY.md 超过此字符数时提示压缩
  keep_recent_decisions: 5  # 压缩时保留最近 N 条决策
  keep_recent_completed: 3  # 压缩时保留最近 N 条完成记录
```

### 添加自定义分区

在 `hot_layer.sections` 中新增任意分区，下次 Session 自动识别：

```yaml
    - name: "API Contracts"
      description: "项目依赖的外部 API 及其注意事项。"
      max_items: 15
      format: "- [服务] 端点 | 注意事项"
```

---

## 命令参考

| 命令 | 使用时机 |
|---|---|
| `/memory-loop:save` | 任务完成后，将本次 session 的学习写入 MEMORY.md |
| `/memory-loop:status` | 查看文件大小、各分区健康状态和压缩建议 |
| `/memory-loop:compress` | 收到大小警告后，将旧条目归档到 archive.md |

---

## 设计理念

**为什么是项目级而非全局？**
记忆具有项目特异性。A 项目的决策和已知坑对 B 项目来说是噪声。

**为什么用 Markdown 而非向量数据库？**
在单个项目的工作记忆规模下，全量注入比语义检索更可靠——不会有检索盲区，不会漏掉关键的 Gotcha。文件增大时，`/memory-loop:compress` 将旧条目归档，热冷分层随时间自然形成，而非在写入时强制判断。

**为什么是提示压缩而非自动压缩？**
压缩意味着信息迁移，这应该是主动行为，而非悄悄丢失你可能还需要的 context。

**为什么不写入 CLAUDE.md？**
CLAUDE.md 是一次性写入的项目规范，MEMORY.md 是每次 session 都会变化的动态状态。混在一起两者都难以管理。

---

## 环境要求

- Claude Code v2.0+
- bash（macOS / Linux / WSL）
- `yq`（可选，用于读取 schema 中的压缩阈值配置）

```bash
brew install yq   # macOS
snap install yq   # Linux
```

---

## 参与贡献

欢迎提 Issue 和 PR。

如果你为特定领域（芯片设计、数据科学、游戏开发等）定制了 schema，欢迎将其贡献到 `examples/` 目录，让其他人可以直接使用。

---

## 许可证

MIT © [yucai0302](https://github.com/yucai0302)

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yucai0302/memory-loop&type=Date)](https://star-history.com/#yucai0302/memory-loop&Date)
