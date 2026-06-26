# Section Roadmap — Metrics (Phase 5)

> Tool-agnostic syllabus + a decision arena we fill **during** learning. Tools are NOT finalized here.

## 0. Metadata
- **Section / Phase:** `10-Metrics` / Phase 5
- **Status:** `Not started`
- **Depends on:** 01-Fundamentals (cardinality, SLOs, OTel), 02-Linux, 04-Storage (LSM/compaction)
- **Target outcome:** _I can design, scale, and cost a metrics platform for 1B+ active series and
  defend every tool, failure mode, and dollar._

## 1. Business Problem (at hyperscale)
Metrics are the cheapest, densest signal and the economic model for everything else. At a hyperscaler:
**1B+ active series**, multi-region, 13-month retention, 99.9% query availability, millions of
samples/sec ingest. The platform itself becomes a massive distributed TSDB whose failure blinds the
whole company. The dominant cost/failure driver is **cardinality**, not query volume.

## 2. Learning Objectives
- I can explain Prometheus TSDB internals (head/WAL/blocks, compaction) and PromQL execution.
- I can quantify and control **cardinality** and design per-team budgets/chargeback.
- I can choose and defend a scaling path (Prometheus → Thanos / Mimir / VictoriaMetrics) on cost+ops.
- I can size remote-write, HA pairs/dedup, and query fan-out, and compute the capacity/cost math.
- I can design multi-window multi-burn-rate SLO alerts.

## 3. Concepts to Master — the syllabus (TOOL-AGNOSTIC)
- [ ] Time-series data model: series = metric name + label set; what makes a series "active"
- [ ] Pull vs push; scrape model; service discovery; relabeling (the cardinality control point)
- [ ] TSDB internals: head block, WAL, 2h blocks, compaction lifecycle, retention
- [ ] PromQL execution model: instant vs range vectors, rate/irate, aggregation, query cost
- [ ] **Cardinality math** — the master variable; combinatorial label explosion; memory per series
- [ ] Histograms: classic vs native/exponential; quantile estimation error; exemplars (→ traces)
- [ ] Recording rules (pre-aggregation) vs alerting rules
- [ ] Remote-write protocol: queue, shards, backpressure, WAL replay
- [ ] Long-term storage & downsampling; hot vs object-storage tiers
- [ ] HA: redundant scrapers + deduplication; the "two Prometheis disagree" problem
- [ ] Federation vs remote-write vs query-federation (and when each is wrong)
- [ ] Multi-tenancy: per-tenant limits, isolation, noisy-neighbor
- [ ] **The signature failure mode: cardinality explosion → ingester OOM / query death**

## 4. Signals in This Domain
| Signal | What to collect | Why it matters | Cardinality/cost risk |
|---|---|---|---|
| Metrics | counters, gauges, histograms, summaries | RED/USE golden signals; cheap aggregates | **HIGH** — unbounded labels (user_id, pod, path) kill it |
| Exemplars | trace IDs on histogram buckets | the metrics→traces bridge | low |
| Metadata | target labels, help/type | discovery, dashboards | medium (target churn) |

## 5. 🏟️ Tool Decision Arena — *to fill DURING learning*

### 5a. Decision criteria / scorecard (weights tuned to your context)
| Criterion | Weight | Notes |
|---|---|---|
| Scale ceiling (→ 1B+ active series) | High | Single Prometheus dies ~1–10M; need a scaling tier |
| Operational complexity | High | Mimir = microservices (heavy); VictoriaMetrics = lean; Thanos = bolt-on |
| Cost / unit economics ($/M active series, RAM/series) | High | VM famously RAM-efficient; Mimir compute-heavy |
| Ecosystem & adoption | Med | Prometheus is the gravity well; PromQL everywhere |
| Lock-in / portability | Med | all speak Prometheus/PromQL; remote-write standard |
| Local-buildability (~$0 on Mac) | High | all run in Docker; VM/Prom simplest single-node |
| OSS | High | all OSS (note Grafana/VM licensing nuances) |
| Fit to failure modes | High | how each handles cardinality + HA dedup |

### 5b. Candidate tools (seed — **you add/strike, bring industry research**)
| Per signal | Candidates to evaluate | Your suggestions |
|---|---|---|
| Scrape/collect | Prometheus, VictoriaMetrics-agent, OTel Collector, Grafana Alloy | _← add_ |
| Long-term/scale | **Thanos** vs **Mimir/Cortex** vs **VictoriaMetrics** | |
| Storage backend | object storage (S3/Azure Blob/MinIO) | |
| Alerting | Alertmanager, Grafana Alerting | |
| SLO rules | Sloth, Pyrra | |
| Dashboards | Grafana (mandated) | |
| Managed (compare-only) | Azure Managed Prometheus, Datadog, GCP Monitoring | |

### 5c. 📝 Decision Log
| Date | Decision (chosen → over) | Rationale | Trade-off accepted |
|---|---|---|---|
| _empty — we fill this together_ | | | |

### 5d. Answer-key check
Reference architecture chose **Prometheus → Mimir** (VictoriaMetrics as the lean challenger). After
*you* decide, compare and defend any divergence here.

## 6. Architecture (design before tools) — _to draft during learning_
Tool-agnostic flow: `scrape/receive → (relabel/drop) → local TSDB → remote-write → long-term store
(object storage) → query fan-out → Grafana`. Overlay tools after the decision.

## 7. Design Decisions & Trade-offs — _to fill_
Push vs pull · where to drop cardinality (agent vs ingest) · HA dedup strategy · downsampling tiers ·
recording-rule pre-aggregation · tenant isolation.

## 8. 🔬 Labs — *to define during learning* (seed ideas)
- [ ] Lab: single Prometheus + Grafana + a demo app locally
- [ ] Lab: **drive cardinality explosion with `avalanche`** → watch heap death → fix with relabeling
- [ ] Lab: add remote-write to a scaling backend; saturate the queue; observe backpressure
- [ ] Lab: HA pair + dedup; kill one; verify no gaps/dupes
- [ ] Lab: capacity/cost math for 1B series (RAM, nodes, object-storage GB, $/month)

## 9. Failure Modes to Reproduce
1. Cardinality explosion → ingester/Prometheus OOM
2. Remote-write queue saturation → backpressure / data loss
3. Slow/expensive PromQL → query OOM, fan-out timeout
4. HA dedup gaps/duplicates on scraper failover
5. Compaction/storage cliff (block churn, object-store throttling)

## 10. Capacity & Cost Model — _to compute in lab_
series count × bytes/series (RAM) → ingesters; samples/sec → CPU; retention × series → object-store
GB → $/month. Output: a defensible $/million-active-series number.

## 11. Monitoring, Alerting & Dashboard Strategy — _to fill_
Meta-monitor the metrics platform itself (ingester health, queue length, query latency); symptom-based
SLO burn alerts; the 3 dashboards: fleet overview, per-tenant cardinality/cost, platform internals.

## 12. Principal Interview Questions (to answer as we learn)
1. Design a metrics platform for 1B active series, multi-region, 13-month retention. Walk the stack.
2. Mimir vs VictoriaMetrics — when do you pick which, and why? Defend on cost and ops.
3. A team's cardinality 10×'d overnight and Prometheus OOM'd. Diagnose and prevent recurrence.
4. Explain remote-write backpressure and how you'd size the queue.
5. How do multi-window multi-burn-rate alerts work and why two windows?

## 13. Open Questions / Research Backlog — _you drive_
- VictoriaMetrics vs Mimir real-world RAM/$ benchmarks at our scale?
- Native histograms — production-ready? migration cost?
- Where exactly to drop cardinality: agent relabel vs Collector vs ingest limits?

## 14. Definition of Done
- [ ] §3 concepts checked · [ ] §5 tools decided+logged · [ ] §8 lab built + failure reproduced
- [ ] §10 cost model written · [ ] §12 questions answerable · [ ] architecture design doc written
