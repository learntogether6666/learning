# STATUS — Portable Context & Progress Log

> **Purpose:** This file is the portable brain for the learning journey. It lives in the repo (unlike
> Claude's machine-local memory at `~/.claude`), so on ANY laptop, Claude can read this first and
> resume exactly where we left off. **Update it at the end of every session.**
>
> **If you're Claude reading this on a fresh machine:** read this file + `00-Roadmap/README.md` +
> `18-Architecture Patterns/00-Reference-Platform-Architecture.md` to reload full context.

---

## Who & Goal
- **User:** Staff-level infra engineer → targeting **Senior Staff / Principal Observability Engineer**.
- **Timeline:** ~6 months from 2026-06-26 (target ~Dec 2026) to interview-ready.
- **Strategy (honest-bridge):** user has NOT operated million/billion-scale in prod. We do NOT
  fabricate history. We build genuine reasoning depth + portfolio **design docs** + **labs that
  reproduce real hyperscale failure physics at small scale** (synthetic load → real failure → math).
- **Learning style:** hands-on, a **lab for every case**. Parallel track: per session = concept module
  + lab + system-design drill.
- **Budget:** personal Azure $150/mo → ~70% labs local (Docker/kind, $0); Azure spot + teardown only;
  GPU = short spot bursts + simulated scale. Lab 0 = Azure cost guardrails.
- **Scale story priority:** Metrics/Reliability first → AI-infra/GPU as differentiator.

## Tooling & Workflow Decisions
- **Format:** Markdown + **Mermaid** diagrams. (Google Docs only for shareable exports.)
- **Storage/sync:** private GitHub repo `learntogether6666/learning`, cloned on work + personal
  laptops. View in Obsidian / VS Code.
- **Tool selection:** DEFERRED & COLLABORATIVE. Each section uses `SECTION-ROADMAP-TEMPLATE.md`
  (Tool Decision Arena). User suggests tools / brings industry research; we score, debate, log the why.
  `18-Architecture Patterns/00-Reference-Platform-Architecture.md` = the **answer key**, not a mandate.
- A section is "done" only when: concepts checked + tools logged + lab built & failure reproduced +
  cost model written + interview Qs answerable + design doc written.

## Repo Map (what exists)
- `README.md` (repo root) — handbook overview + domain map.
- `Observability/00-Roadmap/` — README (master roadmap, 20 phases), LEARNING-STRUCTURE, MATURITY-MODEL,
  TOOL-DECISION-MATRIX, SECTION-ROADMAP-TEMPLATE, **this STATUS file**.
- `Observability/18-Architecture Patterns/00-Reference-Platform-Architecture.md` — opinionated full
  platform (answer key).
- `Observability/10-Metrics/00-roadmap.md` — first instantiated section roadmap (worked example).
- Folders `01`–`24` created; most section roadmaps not yet stamped.

## Progress Log (newest first)
| Date | What happened | Next |
|---|---|---|
| 2026-06-29 | **Launched `AI-Infra/` as a top-level domain** (scope decision resolved: build+operate, NOT just Phase 14 observability). Drafted two production-grade reference docs from user's "LearnAI" prompt: **Section 1 — AI Infrastructure Foundations** (`AI-Infra/01-Foundations/`): GPU compute (H100/H200/GB200, SMs/Tensor Cores/HBM), CUDA stack (NCCL/cuDNN/cuBLAS/CUDA Graphs/Transformer Engine), NVLink/NVSwitch, InfiniBand+SHARP, storage (NVMe-oF/GDS/parallel FS), DP/TP/PP/EP/ZeRO parallelism, 2T memory math, FP8 stability, checkpoints. **Section 2 — LearnAI Production Stack** (`AI-Infra/02-Production-Stack/`): 4-region design, T/FT/I clusters, model lifecycle+placement, adapter multiplexing, real-time inference physics (prefill/decode disaggregation, KV cache, continuous batching, TTFT/ITL SLOs), failover + goodput math, team model, observability control loop, economics. Added missing components (power/cooling, scheduling, collectives, economics) flagged as "ADDED". + `AI-Infra/README.md`. | Build per-section LABS (local-first: kind + DCGM exporter + tiny vLLM serve → reproduce KV-cache pressure / continuous batching / simulated straggler → goodput collapse). Tool-decision arena: vLLM vs TRT-LLM vs SGLang. Interview Q-banks. |
| 2026-06-29 | Completed GitHub setup: repo `learntogether6666/learning` pushed (scaffold + CLAUDE.md + hardened .gitignore). Token kept in gitignored `.token`; credentials ISOLATED in repo-local `.git/.personal-credentials` (work keychain/SSH untouched, fully walled off). Cross-laptop continuity verified (CLAUDE.md → STATUS.md). **User pivoting focus from Observability → AI Infrastructure.** | Fresh session: scope AI-Infra. Decide top-level `AI-Infra/` domain vs Observability Phase 14. |
| 2026-06-26 | Built roadmap, learning template, maturity model, tool matrix, reference architecture, section-roadmap template, Metrics section roadmap. Agreed deferred-tools workflow; md+Mermaid+GitHub. Set up Git repo. | Decide: stamp all section roadmaps vs start learning Metrics. |

## Current Position
- **Active domain:** **`AI-Infra/`** (new top-level domain — scope decision RESOLVED: build+operate hyperscale AI infra, NVIDIA-only, twin focus = 2T training + real-time inference).
- **Done:** `AI-Infra/` Section 1 (Foundations) + Section 2 (Production Stack) + README drafted as production-grade reference docs. Both Mermaid-rich, hyperscale numbers, failure modes, economics. "Missing" components added & flagged.
- **Next:** (1) per-section **labs** — local-first kind + DCGM exporter + tiny vLLM serve to reproduce KV-cache pressure, continuous batching, simulated-straggler → goodput collapse; (2) **tool-decision arena** for inference engines (vLLM vs TensorRT-LLM vs SGLang) using the Tool Decision Arena template; (3) **interview Q-bank** per section; (4) **cost model** ($/token, $/training-run, MW capacity).
- **Note:** Observability remains scaffolded and ready to resume anytime (Metrics is the first learning target there; Phase 14 cross-links to this new domain).

## How to Resume (checklist for any new session/machine)
1. Read this STATUS.md.
2. Skim `00-Roadmap/README.md` for the phase map.
3. Check the "Current Position" above for the active section.
4. Continue; update the Progress Log + Current Position before ending the session.
