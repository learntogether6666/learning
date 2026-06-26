# Section Roadmap Template

> Copy this into each numbered domain folder as `00-roadmap.md`. It defines **what to learn**
> (tool-agnostic) and provides a **structured arena to decide tools during the learning phase** —
> rather than finalizing tools up front. Tools are chosen collaboratively, defended in the Decision
> Log, then compared against the opinionated reference architecture as an answer key.
>
> Sequence we follow per section: **understand the problem → master the concepts → design
> (tool-agnostic) → decide tools (the arena) → build the lab → break it → write the design doc.**

---

## 0. Metadata
- **Section / Phase:** `<NN-Name>` / Phase `<n>`
- **Status:** `Not started | Learning | Tools decided | Lab built | Done`
- **Depends on:** `<earlier sections>`
- **Target outcome (one sentence):** _what you can do when this is "done"._

## 1. Business Problem (at hyperscale)
_The real, expensive problem this domain solves at the scale of Meta/OpenAI/Microsoft/LinkedIn.
Numbers: volume, scale, SLA pressure. Why it matters in dollars._

## 2. Learning Objectives
_3–6 capabilities you will own. Phrased as "I can design / reason about / defend …"._

## 3. Concepts to Master — the syllabus (TOOL-AGNOSTIC)
_The checklist of ideas that are true regardless of tooling. This is the durable knowledge._
- [ ] concept …
- [ ] concept …
- [ ] the dominant **failure mode** of this domain
- [ ] the **cardinality / cost / sampling / tiering** angle specific to this domain

## 4. Signals in This Domain
_What telemetry actually exists here, by type. Tool-agnostic — just the data._

| Signal | What to collect | Why it matters | Cardinality/cost risk |
|---|---|---|---|
| Metrics | | | |
| Logs | | | |
| Traces | | | |
| Profiles | | | |
| Other (domain-specific) | | | |

## 5. 🏟️ Tool Decision Arena — *filled DURING the learning phase*

> We do NOT pre-pick. We list candidates, score against criteria, debate (you bring suggestions /
> industry research), then record the decision and the *why*. This section is the interview gold.

### 5a. Decision criteria / scorecard
_Weight per your context (you're OSS-first, local-buildable, $150/mo Azure, Principal-interview goal)._

| Criterion | Weight | Notes |
|---|---|---|
| Scale ceiling (does it reach our target scale?) | | |
| Operational complexity (ops load to run it) | | |
| Cost / unit economics ($/series, $/GB, $/scan…) | | |
| Ecosystem & adoption (who runs it, community) | | |
| Lock-in / portability (OTel-friendly?) | | |
| Local-buildability (can you lab it on a Mac, ~$0?) | | |
| OSS (open source preferred) | | |
| Fit to THIS domain's failure modes | | |

### 5b. Candidate tools (seed list — **you add/strike**)
| Per signal | Candidates to evaluate | Your suggestions / industry research |
|---|---|---|
| Metrics | _e.g._ Prometheus, VictoriaMetrics, Thanos, Mimir | _← add here_ |
| Logs | Loki, ClickHouse, Elastic/OpenSearch | |
| Traces | Tempo, Jaeger, Zipkin | |
| Profiling | Pyroscope, Parca | |
| Alerting | Alertmanager, Grafana Alerting | |
| Dashboards | Grafana (mandated) | |
| Domain-specific | _exporters/agents for this domain_ | |

### 5c. 📝 Decision Log
| Date | Decision (chosen → over) | Rationale (the defendable why) | Trade-off accepted |
|---|---|---|---|
| | | | |

### 5d. Answer-key check
_After deciding, compare to `18-Architecture Patterns/00-Reference-Platform-Architecture.md`.
Did you match? If you diverged, can you defend why? Record the delta — this is interview prep._

## 6. Architecture (design BEFORE tools)
_Draw the data flow tool-agnostically first: instrument → collect → process → store → query.
Then overlay the chosen tools. Forces design thinking over tool worship._

## 7. Design Decisions & Trade-offs
_The hard calls specific to this domain (push vs pull, sampling, aggregation, tiering, isolation)._

## 8. 🔬 Labs — *defined DURING the learning phase*
_Each lab = build it → drive it into a failure mode → measure → fix. Local-first._
- [ ] Lab: stand up the chosen stack locally (compose/kind)
- [ ] Lab: reproduce the domain's signature failure mode (synthetic load)
- [ ] Lab: do the capacity/cost math for 1000× scale
- [ ] _added during learning…_

## 9. Failure Modes to Reproduce
_The top 5 ways this domain breaks in production — that we will deliberately trigger in a lab._
1.
2.

## 10. Capacity & Cost Model
_The math: volume → resources → dollars. Unit economics. The senior-staff differentiator._

## 11. Monitoring, Alerting & Dashboard Strategy
_How you observe this domain (incl. meta-monitoring), symptom-based alerts, the 3 dashboards
that matter._

## 12. Principal Interview Questions
_The hard questions for this domain, with model-answer notes captured as we learn._
1.
2.

## 13. Open Questions / Research Backlog
_Where you park tools to investigate, debates to have, things to verify. You drive this list._

## 14. Definition of Done
- [ ] Concepts (§3) all checked
- [ ] Tools decided + logged (§5)
- [ ] Lab built and a failure reproduced (§8)
- [ ] Capacity/cost model written (§10)
- [ ] Interview questions answerable (§12)
- [ ] Architecture design doc written
```
```
