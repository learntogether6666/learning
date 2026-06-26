# Observability Maturity Model & Self-Assessment

Use this to locate yourself honestly and to target the next jump. The goal of this handbook is to
move you from **L3 → L5**. Rate yourself per row, not overall — most engineers are L4 in metrics and
L2 in AI-infra. That spread is normal; close it phase by phase.

## The five levels

| Level | Name | Defining capability |
|------:|------|----------------------|
| **L1** | Monitoring | Static dashboards, threshold alerts, "is it up?" Known-unknowns only. |
| **L2** | Instrumented | Three signals collected; can debug known problem classes; reactive. |
| **L3** | Observable | High-cardinality data; can ask new questions without redeploying; SLOs exist. |
| **L4** | Engineered | Telemetry is a platform: multi-tenant, cost-governed, sampled deliberately, OTel-standardized. |
| **L5** | Hyperscale Platform | You *design* the platform: petabytes, 1B+ series, cost unit-economics, DR for the telemetry system itself, frontier (AI/MLOps) coverage. Org-wide influence. |

## Self-assessment grid

Score each domain 1–5. Re-score after each phase.

| Domain | L-now | L-target | Phase that moves it |
|--------|:----:|:-------:|---------------------|
| Fundamentals (cardinality, SLO, OTel, sampling) | | 5 | 1 |
| Linux / host | | 5 | 2 |
| Network (incl. AI fabric) | | 5 | 3 |
| Storage | | 4 | 4 |
| Metrics platform | | 5 | 5 |
| Logging platform | | 5 | 6 |
| Tracing & sampling | | 5 | 7 |
| Profiling | | 4 | 8 |
| eBPF | | 4 | 9 |
| Kubernetes (incl. GPU) | | 5 | 10 |
| Azure | | 5 | 11 |
| Application | | 5 | 12 |
| API monitoring | | 4 | 13 |
| AI infrastructure | | 5 | 14 |
| MLOps | | 4 | 15 |
| Security observability | | 4 | 16 |
| SRE practice | | 5 | 17 |
| Architecture / platform design | | 5 | 18 |

## The L4 → L5 markers (what actually separates Senior Staff)

1. You argue tool choices in **dollars per unit of insight**, not features.
2. You design **cardinality budgets and chargeback**, not just dashboards.
3. You have a **defensible sampling strategy** that stays statistically honest.
4. You plan **DR for the observability platform itself**.
5. You can cover the **frontier** (GPU clusters, LLM serving, model drift), not just web services.
6. You drive **org-wide adoption and standards**, not just your own team's telemetry.

If you can't yet claim all six, the phase map tells you exactly where to go.
