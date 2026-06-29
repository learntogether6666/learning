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
| 2026-06-29 | Completed GitHub setup: repo `learntogether6666/learning` pushed (scaffold + CLAUDE.md + hardened .gitignore). Token kept in gitignored `.token`; credentials ISOLATED in repo-local `.git/.personal-credentials` (work keychain/SSH untouched, fully walled off). Cross-laptop continuity verified (CLAUDE.md → STATUS.md). **User pivoting focus from Observability → AI Infrastructure.** | Fresh session: scope AI-Infra. Decide top-level `AI-Infra/` domain vs Observability Phase 14. |
| 2026-06-26 | Built roadmap, learning template, maturity model, tool matrix, reference architecture, section-roadmap template, Metrics section roadmap. Agreed deferred-tools workflow; md+Mermaid+GitHub. Set up Git repo. | Decide: stamp all section roadmaps vs start learning Metrics. |

## Current Position
- **Phase:** Setup complete. Observability scaffold built; learning not yet started. **Pivoting to AI Infrastructure.**
- **Active section:** none yet. User wants to switch gears to **AI Infra**.
- **Open decision for next (fresh) session:** Is "AI Infra" the planned **top-level `AI-Infra/` domain** (broader: GPU clusters, training/inference infra) or **Observability Phase 14** (AI-infra *observability* within the Observability track)? Scope it, then build its roadmap from `SECTION-ROADMAP-TEMPLATE.md` (or a domain README if top-level).
- **Note:** Observability remains scaffolded and ready to resume anytime (Metrics is the first learning target there).

## How to Resume (checklist for any new session/machine)
1. Read this STATUS.md.
2. Skim `00-Roadmap/README.md` for the phase map.
3. Check the "Current Position" above for the active section.
4. Continue; update the Progress Log + Current Position before ending the session.
