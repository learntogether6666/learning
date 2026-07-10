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
| 2026-07-10 | **AKS Lab 01: cluster foundation built.** Skipped the planned `kind` step and went straight to real AKS (user call: AKS-specific skills — node pools, Spot/Regular priority, autoscaling, cost mgmt — are directly interview-relevant). Tooling: **OpenTofu**, not Terraform (Terraform is BSL-licensed since v1.5.0, not OSI open source; OpenTofu is the MPL-2.0 drop-in fork). IaC lives in new top-level `Azure/infra/` (separate from lab docs — this cluster is shared infra, not a one-off lab artifact): `bootstrap/` (remote state: `rg-tofu-state`, `sttofuaksvsr02`) + `aks-cluster/`. Cluster `aks-observability-lab` / `rg-aks-observability-lab` / eastus, **AKS Free tier**, Azure CNI Overlay, no Container Insights add-on (avoids Log Analytics billing). Node pools: `system` (`Standard_B2s`, tainted `CriticalAddonsOnly`) + `general` (`Standard_D2s_v3`, autoscale 1-3). **Mid-build correction:** first build landed in DCGM lab's subscription (`0a5a25eb`) — user wanted AKS in a **separate** subscription (`a04c60cd`, same `Vidya@...` VS Enterprise account) for budget isolation; cleanly `tofu destroy`'d both stacks and rebuilt in `a04c60cd`. **Spot capacity unavailable** for both `Standard_B2s` and `Standard_D2s_v3` in eastus (`SkuNotAvailable`, twice) — fell back to Regular/on-demand priority for `general`. Verified: `kubectl get nodes`/`get pods -A` clean, `az aks stop`/`start` round-trip tested working. Created `AI-Infra/Labs/AKS-Lab-01.md` (architecture, node-pool taxonomy for future training/inference/GPU-sim workloads, cost model, build-log lessons, 5 interview Q&A) + `Azure/infra/README.md`. Saved memory: cluster login/access + OpenTofu preference. | (1) Tool-decision arena for the observability stack (metrics/logs/traces choices), add one component at a time starting with metrics+Grafana; (2) Port fake-DCGM exporter into a K8s DaemonSet on `general`; (3) `az aks stop` when not in use. |
| 2026-07-06 | **DCGM Lab 01 built on Azure.** Logged into VS Enterprise subscription (`0a5a25eb`). GPU VM quota = 0 for all modern SKUs (NC/NV retired, T4 needs quota request). Deployed `Standard_B2s` spot VM (`vm-dcgm-lab`, `20.25.43.14`, `rg-dcgm-lab`, eastus). Installed DCGM 3.3.9 native + Docker Compose stack: fake DCGM metrics server (Python, 2x H100 SXM5 simulated, exact Prometheus schema) + Prometheus (9090) + Grafana (3000). All services live. Created `AI-Infra/Labs/DCGM-Lab-01.md` (~2,500 lines): DCGM architecture deep-dive, full CLI hands-on, Prometheus+Grafana setup, **8 production troubleshooting scenarios** (thermal throttle, XID 79, ECC page retirement, OOM, straggler, power cap, NVLink saturation, K8s gap), failure injection scripts, GPU Operator/K8s section, **20 interview Q&A**, cost model. | (1) Wire Grafana dashboard ID 12239 + build custom panels; (2) Run failure injection scenarios one-by-one; (3) T4 quota request for real GPU; (4) Kind + DCGM exporter local lab for K8s integration path. |
| 2026-06-29 | **RESTRUCTURED `AI-Infra/` into a 9-level graduate course** (user rejected v1 monolithic docs as "not deep / not explained / bad diagrams"; then shared a ChatGPT sample showing the wanted style: progressive "build a city" levels, teach-first with analogies, then hyperscale depth). New pedagogy approved via a Level-1 exemplar, then fanned out 8 parallel subagents. **Foundations/** (L1 GPU Architecture, L2 Single GPU Server, L3 Multi-GPU Server/NVLink, L4 Rack Design, L5 Network Fabric/InfiniBand, L6 Storage & Data Pipeline). **Production/** (L7 Distributed Training, L8 AI Supercomputer incl. heavy real-time inference, L9 Physical AI Infrastructure incl. economics/org/datacenter). Each level: intuition+analogy → building diagrams → real numbers/math → failure modes → interview Q&A → next-level bridge. ~4,300 lines, 50 Mermaid diagrams, all fences balanced & linted. Deleted v1 `01-Foundations/` + `02-Production-Stack/`. Rewrote `AI-Infra/README.md` as the course map. | Per-level LABS (kind + DCGM + tiny vLLM → KV-cache pressure / continuous batching / simulated straggler → goodput collapse). Inference-engine tool-arena (vLLM vs TRT-LLM vs SGLang). Cost model. |
| 2026-06-29 | **Launched `AI-Infra/` as a top-level domain** (scope decision resolved: build+operate, NOT just Phase 14 observability). Drafted two production-grade reference docs from user's "LearnAI" prompt: **Section 1 — AI Infrastructure Foundations** (`AI-Infra/01-Foundations/`): GPU compute (H100/H200/GB200, SMs/Tensor Cores/HBM), CUDA stack (NCCL/cuDNN/cuBLAS/CUDA Graphs/Transformer Engine), NVLink/NVSwitch, InfiniBand+SHARP, storage (NVMe-oF/GDS/parallel FS), DP/TP/PP/EP/ZeRO parallelism, 2T memory math, FP8 stability, checkpoints. **Section 2 — LearnAI Production Stack** (`AI-Infra/02-Production-Stack/`): 4-region design, T/FT/I clusters, model lifecycle+placement, adapter multiplexing, real-time inference physics (prefill/decode disaggregation, KV cache, continuous batching, TTFT/ITL SLOs), failover + goodput math, team model, observability control loop, economics. Added missing components (power/cooling, scheduling, collectives, economics) flagged as "ADDED". + `AI-Infra/README.md`. | Build per-section LABS (local-first: kind + DCGM exporter + tiny vLLM serve → reproduce KV-cache pressure / continuous batching / simulated straggler → goodput collapse). Tool-decision arena: vLLM vs TRT-LLM vs SGLang. Interview Q-banks. |
| 2026-06-29 | Completed GitHub setup: repo `learntogether6666/learning` pushed (scaffold + CLAUDE.md + hardened .gitignore). Token kept in gitignored `.token`; credentials ISOLATED in repo-local `.git/.personal-credentials` (work keychain/SSH untouched, fully walled off). Cross-laptop continuity verified (CLAUDE.md → STATUS.md). **User pivoting focus from Observability → AI Infrastructure.** | Fresh session: scope AI-Infra. Decide top-level `AI-Infra/` domain vs Observability Phase 14. |
| 2026-06-26 | Built roadmap, learning template, maturity model, tool matrix, reference architecture, section-roadmap template, Metrics section roadmap. Agreed deferred-tools workflow; md+Mermaid+GitHub. Set up Git repo. | Decide: stamp all section roadmaps vs start learning Metrics. |

## Current Position
- **Active domain:** **`AI-Infra/`** — Labs track now active alongside the course content.
- **Done:**
  - 9-level graduate course (`Foundations/` L1–6 + `Production/` L7–9), ~4,300 lines, 50 Mermaid diagrams
  - **DCGM Lab 01** (`AI-Infra/Labs/DCGM-Lab-01.md`, ~2,500 lines): Azure VM live at `20.25.43.14`, fake H100 metrics → Prometheus → Grafana stack running, 8 troubleshooting scenarios, 20 interview Q&A
  - **AKS Lab 01** (`AI-Infra/Labs/AKS-Lab-01.md`): AKS cluster `aks-observability-lab` live in `eastus`, `system`+`general` node pools, verified working, stop/start tested
- **Azure lab VM (DCGM):** `vm-dcgm-lab` / `rg-dcgm-lab` / eastus / `20.25.43.14` — subscription `0a5a25eb...`. SSH key at `~/.ssh/dcgm_lab_key`. **Deallocate when not in use:** `az vm deallocate -g rg-dcgm-lab -n vm-dcgm-lab`. Restart: `az vm start -g rg-dcgm-lab -n vm-dcgm-lab`.
- **Azure AKS cluster:** `aks-observability-lab` / `rg-aks-observability-lab` / eastus — subscription `a04c60cd...` (**separate from the DCGM VM's subscription** — different VS Enterprise account, kept apart deliberately for budget isolation). IaC in `Azure/infra/` (OpenTofu). **Stop when not in use:** `az aks stop -g rg-aks-observability-lab -n aks-observability-lab`. Start: `az aks start -g rg-aks-observability-lab -n aks-observability-lab`.
- **Next:**
  1. **Observability stack tool-decision arena** — metrics/logs/traces tool choices for the AKS cluster, then add one component at a time starting with metrics + Grafana (per `SECTION-ROADMAP-TEMPLATE.md`)
  2. **Port fake-DCGM exporter into AKS** as a DaemonSet on the `general` pool (K8s integration path, supersedes the old standalone "Kind + DCGM" plan since we went straight to real AKS)
  3. **DCGM Lab 01 exercises** — run failure injection scenarios (thermal spike, XID 79, ECC, straggler, power cap) one at a time; wire Grafana dashboard 12239
  4. **T4 quota request** — file via Azure portal for `Standard_NCASv3_T4` in eastus to get real GPU for future labs
  5. **vLLM inference lab** — KV-cache pressure / continuous batching / goodput collapse
  6. **Tool-decision arena** — vLLM vs TRT-LLM vs SGLang
- **Note:** Observability remains scaffolded and ready to resume anytime.

## How to Resume (checklist for any new session/machine)
1. Read this STATUS.md.
2. Skim `00-Roadmap/README.md` for the phase map.
3. Check the "Current Position" above for the active section.
4. Continue; update the Progress Log + Current Position before ending the session.
