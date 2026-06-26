# Tool Decision Matrix (living document)

A running, opinionated comparison updated as each phase introduces tools. This is the artifact you'd
bring to a build-vs-buy review. **Rule: never name a tool without naming its alternative and the
deciding tradeoff.** Numbers here are order-of-magnitude planning figures, not benchmarks — verify
for your workload.

---

## Metrics

| Tool | Model | Scale ceiling (active series) | Ops load | Cost model | Pick it when… |
|------|-------|------|---------|-----------|---------------|
| **Prometheus** (single) | Pull, local TSDB | ~1–10M / instance | Low | Self-host compute | Single cluster, short retention |
| **Thanos** | Prom + object store, query fan-out | 100M+ | High | Object storage + compute | You're already Prom-native and want global query + cheap long-term |
| **Cortex / Mimir** | Horizontally sharded, blocks | 1B+ | High | Compute-heavy | Massive multi-tenant, you'll run a platform team |
| **VictoriaMetrics** | Single-binary or cluster | 1B+ | **Low–Med** | Best compute efficiency | You want Mimir-class scale at a fraction of the ops/RAM |
| **Datadog** | SaaS | "Unlimited" (you pay) | None | **\$ per host + custom metrics** | Speed-to-value > cost control; small-to-mid scale |
| **Azure Monitor Managed Prometheus** | Managed | High | None | Per-sample ingested | Azure-native, want managed OSS compatibility |
| **CloudWatch / GCP Monitoring** | SaaS | High | None | Per-metric + API calls | Single-cloud, native integration priority |

**Deciding tradeoff:** Prometheus economics break on **cardinality**, not query volume. The whole
table is "how do I scale past one Prometheus" — Thanos (bolt-on), Mimir (re-architect), VictoriaMetrics
(replace), or SaaS (pay someone). At >100M series, VictoriaMetrics vs Mimir is the real fight;
VM usually wins on RAM/\$, Mimir wins on Grafana-stack integration and tenancy maturity.

---

## Logging

| Tool | Index model | Strength | Weakness | Cost driver |
|------|-------------|----------|----------|-------------|
| **Elasticsearch / OpenSearch** | Full-text inverted index | Fast arbitrary search | Index = huge storage + RAM; expensive at PB | Storage + heap |
| **Grafana Loki** | Label index only, no content index | Cheap, Prom-like labels | Slow for needle-in-haystack content search | Object storage (cheap) |
| **ClickHouse** | Columnar, no full-text (or limited) | Blazing analytical scans, best \$/GB at PB | SQL, you operate it; not search-first | Compute on scan |
| **Splunk** | Proprietary index | Powerful SPL, enterprise/SIEM | **Most expensive at scale** | Per-GB ingested |
| **Azure Log Analytics (KQL)** | Managed | KQL, Azure-native, Sentinel tie-in | Cost, lock-in | Per-GB ingested + retention |
| **Datadog / CloudWatch Logs** | SaaS | Integrated | Cost at PB | Per-GB ingest + scan |

**Deciding tradeoff:** the **index philosophy**. Full-text index (Elastic/Splunk) = fast search,
brutal storage cost. Label index (Loki) = cheap storage, slow content search. Columnar (ClickHouse)
= cheapest at PB if your queries are analytical/structured (wide events). The hyperscale trend is
Elastic → ClickHouse/Loki migrations driven purely by cost.

---

## Tracing

| Tool | Storage | Sampling | Pick it when… |
|------|---------|----------|---------------|
| **Jaeger** | Cassandra / ES | Head (mostly) | OSS standard, you have ES/Cassandra ops |
| **Grafana Tempo** | Object storage, trace-by-ID | Works great with tail-sampling collector | Cheap at scale, Grafana stack, don't need rich trace search |
| **Zipkin** | Various | Head | Legacy/simple |
| **Datadog APM / Honeycomb** | SaaS | Tail / dynamic | Best UX & analytics, pay for it |
| **Azure App Insights** | Managed | Adaptive | Azure-native apps |

**Deciding tradeoff:** **sampling strategy + storage cost**, not the UI. Tempo's "object storage,
no index" model is the Loki of traces — cheap, but you find traces by ID/metrics-exemplar, not by
arbitrary search. Honeycomb/Datadog charge for the rich querying you'd otherwise build.

---

## Profiling

Pyroscope (now Grafana) vs Parca (eBPF-native, CNCF) vs Datadog Continuous Profiler vs Google Cloud
Profiler. **Deciding tradeoff:** eBPF whole-system (Parca/Pyroscope-eBPF, zero instrumentation, any
language) vs SDK profilers (richer language detail). Overhead must stay <1% for always-on.

## eBPF observability

Pixie (app/L7, K8s) vs Cilium+Hubble (network/policy) vs Tetragon (security) vs Grafana Beyla
(auto-instrument) vs vendor eBPF agents. **Deciding tradeoff:** eBPF gives zero-instrumentation
breadth but **no business context** and is kernel-version sensitive (CO-RE/BTF). It complements, not
replaces, SDK instrumentation.

---

## The meta-decision: OSS vs SaaS vs Hybrid

| Axis | Self-hosted OSS | SaaS (Datadog/Splunk) | Managed-OSS (Grafana Cloud / Azure Managed) |
|------|------------------|------------------------|----------------------------------------------|
| Upfront cost | Low \$ | High \$ | Medium \$ |
| Ops load | **High** (platform team) | None | Low |
| Cost at hyperscale | **Lowest** (if run well) | **Highest** | Medium |
| Lock-in | Lowest (OTel) | Highest | Medium |
| Time-to-value | Slow | **Fastest** | Fast |

**The hyperscaler pattern:** start SaaS for speed → cost crosses over at scale (commonly \$1–10M/yr)
→ migrate high-volume signals (logs, metrics) to self-hosted OSS while keeping SaaS for low-volume
high-value signals (APM, RUM). **OpenTelemetry is what makes that migration survivable** — instrument
once, re-point the backend. This is *the* recurring senior-staff decision; the build-vs-buy crossover
math belongs in every Phase-18 design doc.

---

*Update this file at the end of each phase with the tools it introduced and the deciding tradeoff
you'd defend in a review.*
