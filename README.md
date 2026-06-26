# Engineering Mastery Handbook

A long-term, hands-on engineering handbook built to take me from **Staff → Senior Staff / Principal**.
OSS-first, lab-driven, written in Markdown with Mermaid diagrams. Synced across laptops via this repo.

## Domains

| Folder | Status | Description |
|---|---|---|
| **[Observability/](./Observability/)** | 🟢 Active | The current focus — end-to-end observability for infra, K8s, Azure, apps, APIs, AI/LLM, MLOps, security. |
| `Kubernetes/` | ⚪ Planned | Deep Kubernetes mastery (sibling domain, added later). |
| `AI-Infra/` | ⚪ Planned | GPU clusters, distributed training/inference infrastructure. |
| `MLOps/` | ⚪ Planned | ML pipelines, model lifecycle, serving. |

## How to use this repo

- **Read order:** start at [`Observability/00-Roadmap/README.md`](./Observability/00-Roadmap/README.md) (the master roadmap).
- **Resume context (any machine):** [`Observability/00-Roadmap/STATUS.md`](./Observability/00-Roadmap/STATUS.md) is the portable progress log — read it first.
- **Viewer:** [Obsidian](https://obsidian.md) (renders Mermaid + `[[links]]`, offline) or VS Code with a Mermaid preview extension.
- **Diagrams:** Mermaid (inline in `.md`, renders on GitHub/Obsidian/VS Code).

## Method

Each domain section follows a tool-agnostic syllabus, then a collaborative **Tool Decision Arena**
(tools chosen during learning, not pre-finalized), then labs that reproduce real failure modes at
small scale, then a written design doc. A section is "done" only when its lab is built and its design
doc is written — not when the reading ends.
