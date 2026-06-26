# The Reference Observability Platform — Architect's Design Document

> **Document type:** Platform architecture / engineering standard
> **Author persona:** Principal Observability Architect, "Project Helios" (internal codename)
> **Scope:** The single observability platform serving every engineering team at a hyperscaler-class
> company (assume scale of Microsoft / Meta / OpenAI / LinkedIn).
> **Mandate:** One platform, OpenTelemetry-standardized instrumentation, **Grafana as the single
> top-level visualization plane**, OSS-first so any team can run a faithful slice locally.
> **Audience:** Every engineering team consumes this platform and follows the guidance here.

This document is opinionated *on purpose*. A platform that offers ten ways to do everything is not a
platform — it's a marketplace. The job of the architect is to **decide once, justify the decision,
and let 2,000 engineers build on a stable foundation.** Where a team has a genuine reason to deviate,
the burden of proof is on them, and this document is what they argue against.

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [The Platform Stack — chosen once](#2-the-platform-stack--decided-once)
3. [Global Architecture](#3-global-architecture)
4. [Section: Infrastructure (Linux / Host)](#4-infrastructure-linux--host-observability)
5. [Section: Kubernetes](#5-kubernetes-observability)
6. [Section: Azure Cloud](#6-azure-cloud-observability)
7. [Section: Networking](#7-network-observability)
8. [Section: Applications](#8-application-observability)
9. [Section: APIs](#9-api-observability)
10. [Section: LLM & Agentic AI](#10-llm--agentic-ai-observability)
11. [Section: AI Infrastructure (GPU)](#11-ai-infrastructure-gpu-observability)
12. [Section: Security](#12-security-observability)
13. [Cross-cutting: Alerting, SLOs, Multi-tenancy, Cost](#13-cross-cutting-concerns)
14. [Build it locally](#14-build-the-whole-thing-locally)
15. [The decisions table (one-glance summary)](#15-one-glance-decision-summary)

---

## 1. Design Principles

These are the axioms. Every tool choice downstream is derived from them.

1. **Instrument once, in a vendor-neutral way.** OpenTelemetry is the instrumentation contract.
   Backends are replaceable; instrumentation embedded in 2,000 services is not. This single principle
   is what makes the platform survivable over a decade.
2. **Separate instrumentation from backend.** Teams emit OTLP. They do not know or care whether logs
   land in Loki or ClickHouse. We can re-point the backend without a single code change.
3. **Cost is a first-class design constraint, not an afterthought.** Every signal has a unit cost
   ($/series, $/GB, $/scan). Observability at this scale is 10–30% of total infra spend; we design
   the economics as deliberately as the reliability.
4. **Cheap by default, expensive on demand.** Default to high-volume/low-cost storage (object
   storage, label indexes, columnar scans). Pay for rich indexing only where the query value justifies
   it.
5. **One pane of glass.** Grafana is the mandated visualization and alerting surface. No team ships
   its own Kibana/Datadog island. Correlation across signals (metric → exemplar → trace → log →
   profile) only works if they live behind one query plane.
6. **The platform must observe itself.** Meta-monitoring is non-negotiable: who watches the watchers.
7. **Sampling and aggregation are honest, documented, and governed.** We never silently drop data in
   a way that hides an outage.
8. **OSS-first.** Every core component is open source and locally runnable. We buy managed services
   only where the operational cost of self-hosting exceeds the license cost at our scale (and we
   document the crossover).

---

## 2. The Platform Stack — decided once

To avoid repeating tool justifications in every section, here is the **house stack**. Domain sections
below describe only their *deltas* and *domain-specific exporters*, not these base choices again.

| Concern | **Chosen** | Primary alternative(s) | One-line reason we chose it |
|---|---|---|---|
| **Instrumentation** | **OpenTelemetry SDKs + auto-instrumentation** | Vendor SDKs, OpenCensus/OpenTracing (dead), Micrometer | Industry standard; vendor-neutral; killed the instrumentation lock-in problem |
| **Zero-code instrumentation** | **eBPF: Grafana Beyla (app/L7) + Cilium/Hubble (network)** | Pixie, vendor eBPF agents | Auto-instrument legacy/polyglot services with no code change |
| **Collection / pipeline** | **OpenTelemetry Collector** (agent DaemonSet + gateway tier) | Grafana Alloy, Fluent Bit, Vector, Telegraf | The neutral funnel for all three signals; processors for sampling/enrichment/routing |
| **Fleet log/metric agent** | **Grafana Alloy** (OTel Collector distro) on hosts | Fluent Bit, Vector | One agent, OTel-native, Prometheus + Loki + Pyroscope aware |
| **Metrics — collection** | **Prometheus** (scrape) | VictoriaMetrics agent, OTel metrics | De-facto standard scrape + PromQL; the gravity well of the ecosystem |
| **Metrics — long-term / scale** | **Grafana Mimir** (multi-tenant, object storage) | **VictoriaMetrics** (lean challenger), Thanos, Cortex | Horizontally scalable to 1B+ series, native multi-tenancy, object-storage economics |
| **Logs — primary** | **Grafana Loki** (label index, no full-text) | Elasticsearch/OpenSearch, ClickHouse | Cheapest at volume; Prometheus-style labels; object storage |
| **Logs — analytical / wide events** | **ClickHouse** | Elasticsearch, Druid | Best $/GB at PB scale for structured/analytical log queries |
| **Traces** | **Grafana Tempo** (object storage, trace-by-id) | Jaeger (+Cassandra/ES), Zipkin | Cheapest trace storage; no index to operate; TraceQL + metrics-from-spans |
| **Trace sampling** | **OTel Collector tail-sampling** | Head sampling, vendor adaptive | Keep 100% of errors/slow traces at <few-% retention cost |
| **Continuous profiling** | **Grafana Pyroscope** (eBPF + SDK) | Parca, vendor profilers | Whole-fleet, low-overhead, Grafana-integrated, flame-graph correlation |
| **Visualization** | **Grafana** | Kibana, Perses, vendor UIs | Mandated single pane; data-source agnostic; the unifying query plane |
| **Alerting — engine** | **Prometheus/Mimir rules + Alertmanager** | Grafana Alerting, Thanos Ruler | Battle-tested routing/dedup/silencing; PromQL alerting |
| **Alerting — unified UI** | **Grafana Alerting** (on top of Alertmanager) | Standalone Alertmanager | Single UI across all data sources; manages the rules |
| **SLO management** | **Sloth / Pyrra** (generate multi-burn-rate rules) | Nobl9 (SaaS), hand-rolled rules | Codifies the Google multi-window burn-rate method as generated PromQL |
| **High-volume transport / buffer** | **Kafka** (Azure Event Hub in cloud) | Pulsar, Redpanda, direct | Decouples producers from backends; absorbs spikes; replayable |
| **Object storage (telemetry backend)** | **S3 / Azure Blob** (MinIO locally) | HDFS, Ceph | Universal cheap durable tier under Loki/Mimir/Tempo |
| **Synthetic monitoring** | **blackbox_exporter + k6** | Grafana Synthetic Monitoring (SaaS), Pingdom | OSS black-box + scriptable multi-step flows |

**The shorthand for this stack is "LGTM+P":** **L**oki, **G**rafana, **T**empo, **M**imir, **P**yroscope —
all unified by OpenTelemetry ingestion and Grafana visualization. This is the Grafana Labs reference
architecture, hardened with ClickHouse (log economics at PB), Kafka (transport), and eBPF (Beyla/
Cilium/Pyroscope) for zero-instrumentation breadth.

### Why this stack over the obvious alternatives (the meta-decision)

- **vs Datadog / New Relic (SaaS all-in-one):** Fastest time-to-value, zero ops — but at our scale the
  bill crosses **\$10M+/yr** and you're locked into their agent and pricing model. We keep SaaS only
  for niche, low-volume/high-value signals if at all. **Crossover math lives in the cost section.**
- **vs Elastic Stack (ELK) for everything:** Elasticsearch is a superb search engine and a *terrible*
  default telemetry store at PB scale — the inverted index is the cost. We use label-indexed Loki and
  columnar ClickHouse instead, reserving full-text search for where it earns its keep.
- **vs Splunk:** Best-in-class enterprise/SIEM SPL, highest cost per GB in the industry. We integrate
  with it for security/compliance where it's already mandated, but never make it the firehose sink.
- **vs cloud-native (Azure Monitor / CloudWatch):** We use these for the *control-plane* signals of
  the cloud itself (where they're the only source of truth) and bridge them into Grafana — but not as
  the platform for our own workloads, to avoid lock-in and per-GB ingestion economics.

---

## 3. Global Architecture

```
                              ┌─────────────────────────── INSTRUMENTATION ───────────────────────────┐
                              │  OTel SDKs (code)   |   Beyla/eBPF (zero-code)   |   Exporters         │
                              │  node_exporter, DCGM-exporter, kube-state-metrics, blackbox_exporter   │
                              └───────────────────────────────┬───────────────────────────────────────┘
                                                              │ OTLP / Prometheus scrape
                  ┌───────────────────────────────────────────▼───────────────────────────────────────┐
   DATA PLANE     │  OTel Collector — AGENT tier (DaemonSet on every node / Alloy on every host)        │
                  │   • batch • resource-detect • redact PII • relabel • drop high-cardinality          │
                  └───────────────────────────────────────────┬───────────────────────────────────────┘
                                                              │
                  ┌───────────────────────────────────────────▼───────────────────────────────────────┐
                  │  OTel Collector — GATEWAY tier (stateful, deployment)                               │
                  │   • TAIL SAMPLING (traces)  • aggregation  • tenant routing  • enrichment           │
                  └───────┬───────────────────┬───────────────────┬───────────────────┬────────────────┘
                          │                   │                   │                   │
                   (optional Kafka / Event Hub buffer for high-volume logs & spikes — replay & backpressure)
                          │                   │                   │                   │
         ┌────────────────▼───┐   ┌───────────▼────────┐  ┌───────▼────────┐  ┌───────▼─────────┐
  STORE  │  Mimir (metrics)   │   │  Loki (logs)       │  │  Tempo (traces)│  │ Pyroscope       │
         │  + Prometheus HA   │   │  + ClickHouse      │  │                │  │ (profiles)      │
         │  pairs             │   │  (wide events)     │  │                │  │                 │
         └────────┬───────────┘   └─────────┬──────────┘  └───────┬────────┘  └────────┬────────┘
                  │                          │                     │                    │
                  └──────────────┬───────────┴──────────┬──────────┴──────────┬─────────┘
                                 │      Object storage (S3 / Azure Blob / MinIO)        │
                                 └─────────────────────────┬───────────────────────────┘
                                                           │
   QUERY / CONSUME    ┌──────────────────────────────────▼──────────────────────────────────┐
                      │  GRAFANA  — dashboards • Explore • correlation (exemplar→trace→log→    │
                      │  profile) • Grafana Alerting UI                                       │
                      │  Alertmanager (route/dedup/silence) → PagerDuty / Slack / Teams       │
                      │  Sloth/Pyrra (SLO rules)                                              │
                      └──────────────────────────────────────────────────────────────────────┘
```

**Control plane vs data plane.** The *data plane* is the agent→gateway→store→query path above. The
*control plane* is everything that configures it: the OTel Collector config (GitOps), Prometheus
scrape/relabel rules, Mimir/Loki/Tempo runtime tenant limits, alert rules (as code), and the
dashboards-as-code pipeline (Grafana provisioning / Grafonnet). **Everything is GitOps.** No
click-ops in production; a dashboard or alert that isn't in Git doesn't exist.

**Two-tier Collector — why.** The **agent tier** (one per node) does cheap, local, stateless work:
batching, PII redaction, resource detection, dropping high-cardinality labels at the source (cheapest
place to do it). The **gateway tier** (a horizontally-scaled deployment) does the expensive *stateful*
work that needs a global view: **tail sampling** (you must see all spans of a trace to decide to keep
it), cross-signal enrichment, and per-tenant routing. Putting tail sampling in the agent would be
wrong — an agent only sees one node's spans.

---

## 4. Infrastructure (Linux / Host) Observability

**Business problem:** 50,000+ hosts across bare-metal, VMs, and VMSS. We need golden host signals
(USE: Utilization/Saturation/Errors) without the per-core/per-device cardinality bankrupting Mimir.

| Signal | Chosen tool | Alternatives | Why chosen |
|---|---|---|---|
| Metrics | **node_exporter** (+ cAdvisor for containers) | telegraf, collectd, Beats/Metricbeat, vendor agents | Canonical, reads `/proc`+`/sys` directly, the metric names everyone's dashboards/alerts already assume |
| Logs | **journald + Alloy → Loki** | Fluentd, Filebeat, rsyslog→ELK | Alloy tails journald/files, attaches labels, ships OTLP/Loki; one agent for logs+metrics+profiles |
| Traces | n/a (host layer) | — | Hosts don't trace; correlation happens at app layer |
| Profiling | **Pyroscope eBPF agent** (whole-host CPU/off-CPU) | Parca, `perf` + pprof | Continuous, <1% overhead, no per-process instrumentation |
| Alerting | **Prometheus rules + Alertmanager** | — | USE-based: saturation (PSI), memory.high breaches, disk fill ETA |
| Dashboards | **Grafana** "Node Fleet" + drill-down | — | Fleet heatmap → single-host USE view |

**Design decisions & trade-offs**
- **Cardinality control is the whole game here.** Per-core CPU and per-device disk metrics on 50k
  hosts is tens of millions of series before you've measured anything useful. Decision: **aggregate
  per-core to per-mode at the agent** (keep `mode`, drop `cpu` label) except on a sampled diagnostic
  fleet; keep per-device only for data disks, not loop/ram devices (relabel-drop). This is a
  representativeness-vs-cost trade we document.
- **PSI (Pressure Stall Information) over load average.** Load average is a famously misleading
  number; cgroup v2 PSI gives true CPU/memory/IO saturation. We alert on PSI, dashboard load average
  only for old-timers' comfort.
- **eBPF profiling chosen over per-service profilers** because at host scale you cannot instrument
  every binary; the eBPF whole-system profiler catches the kernel and unmodified third-party
  processes too.

**Why not a vendor host agent (Datadog Agent):** it's excellent and turnkey, but at 50k hosts the
per-host pricing dominates the bill and you've coupled your entire fleet to one vendor's agent
lifecycle. node_exporter + Alloy is free, and the data is portable.

---

## 5. Kubernetes Observability

**Business problem:** A 10,000-node, multi-tenant, GPU-enabled fleet. The **control plane is itself a
distributed system we must keep alive**, and the data plane is thousands of ephemeral pods whose
identity churns constantly (the cardinality time-bomb of `pod` labels).

| Signal | Chosen tool | Alternatives | Why chosen |
|---|---|---|---|
| Metrics | **Prometheus Operator (kube-prometheus-stack) → Mimir** | Datadog K8s, Azure Monitor Containers, VictoriaMetrics Operator | Operator gives ServiceMonitor/PodMonitor CRDs (declarative scrape); kube-state-metrics + cAdvisor + control-plane scrape |
| Logs | **Alloy DaemonSet → Loki** | Fluent Bit→ES, Promtail, Vector | Alloy auto-discovers pods, attaches k8s metadata labels, ships to Loki |
| Traces | **OTel Collector DaemonSet+Gateway → Tempo** | Jaeger Operator | OTLP from pods, tail-sample at gateway |
| Profiling | **Pyroscope** (eBPF DaemonSet) | Parca | Whole-cluster continuous profiling |
| Network | **Cilium + Hubble** (eBPF) | Calico+NetFlow, kube-proxy metrics | eBPF flow visibility + L7 + network policy, no sidecars |
| Alerting | **Prometheus rules + Alertmanager** | — | Control-plane SLOs, pod-pending, crashloop, etcd health |
| Dashboards | **Grafana** (kube-prometheus mixin dashboards) | — | Curated mixins for API server, etcd, nodes, workloads |

**The signals that actually matter (and that juniors miss):**
- **etcd** is the crown jewel and the most fragile: `etcd_disk_wal_fsync_duration` (p99 fsync —
  the single best predictor of cluster pain), db size vs quota, leader changes, defrag needs. An etcd
  outage is a total cluster outage. This gets its own dashboard and tight alerts.
- **API server**: request latency by verb/resource, inflight requests (the saturation signal),
  priority-and-fairness (APF) rejections, watch cache health.
- **Scheduler**: pending-pod count and scheduling latency (the "why won't my pod start" signal).
- **Autoscaler conflicts**: HPA, VPA, Cluster Autoscaler and KEDA can actively fight each other; we
  dashboard their decisions side-by-side because the failure mode is "they oscillate" not "one breaks."

**Design decisions & trade-offs**
- **Cardinality: drop or hash the `pod` label aggressively.** Ephemeral pod names churn every deploy;
  keeping them as a metric label on high-cardinality metrics explodes Mimir. We keep workload-level
  labels (deployment/namespace) and reserve `pod` granularity for a short-retention high-detail tier.
- **Cilium/Hubble (eBPF) over a service mesh for L4/network visibility** because Istio/Linkerd
  sidecars add latency, memory, and operational weight; eBPF gives flow + L7 visibility with no
  sidecar. We add a mesh **only** where we need mTLS + traffic policy, and then consume Envoy stats.
- **Operator-based scrape (CRDs) over static config** because at 10k nodes you cannot hand-maintain
  scrape configs; teams declare a `ServiceMonitor` and it self-wires.

**Why not Azure Monitor for Containers as primary:** it's the easy AKS default and we *do* bridge its
control-plane signals, but per-GB ingestion + weaker PromQL + lock-in make it wrong as the primary
store for a 10k-node fleet. We run Prometheus→Mimir and pull Azure's unique signals in.

---

## 6. Azure Cloud Observability

**Business problem:** Hundreds of managed-service instances (AKS, Storage, SQL, Cosmos, Redis, Front
Door, App Gateway, Event Hub, Key Vault…) whose internals we *cannot* instrument — only the cloud
provider emits their telemetry. We must ingest that **without** making Azure Monitor our platform.

| Signal | Chosen approach | Alternatives | Why chosen |
|---|---|---|---|
| Metrics | **Azure Monitor → `azuremonitor` receiver / Azure Managed Prometheus → remote-write to Mimir** | Native Azure dashboards only | Pull Azure platform metrics into the *same* Mimir/Grafana plane as everything else |
| Logs | **Diagnostic Settings → Event Hub → OTel Collector → Loki/ClickHouse** | Log Analytics only | Event Hub is the universal Azure log tap; we route, don't lock in |
| Traces | **App Insights (OTel exporter) → also dual-export to Tempo** | App Insights only | Keep Azure-native where mandated, but unify in Tempo |
| Profiling | n/a (managed services) | — | Can't profile managed internals |
| Alerting | **Mimir/Alertmanager** (+ Azure Monitor alerts for platform-only signals) | Azure alerts only | Unify alert routing; Azure alerts bridged into Alertmanager |
| Dashboards | **Grafana** (Azure Monitor data source + Mimir) | Azure Dashboards/Workbooks | Single pane; Azure data source for the few native-only metrics |

**Design decisions & trade-offs**
- **Event Hub is the Azure telemetry backbone.** Diagnostic Settings on every resource → Event Hub →
  our Collector. This is the cloud analog of Kafka and it's how you avoid Log Analytics per-GB
  ingestion costs while keeping all Azure logs.
- **Hybrid by deliberate design.** Azure Managed Prometheus + Managed Grafana exist and are tempting
  for an Azure shop — but we self-host Mimir/Grafana to keep multi-cloud portability and avoid
  per-sample ingestion pricing at our volume. We *use* the managed pieces only to scrape AKS where it
  reduces ops with no lock-in cost.
- **DCR (Data Collection Rules) and Log Analytics retention are cost cliffs.** Where we must use Log
  Analytics (e.g., Azure AD / Entra sign-in logs that only land there), we set aggressive DCR
  filtering and short hot retention, archiving to Blob.

**Why not "just use Azure Monitor for everything":** it's the only source for managed-service
internals (so we ingest it), but as the *platform* it means per-GB economics, weaker query language
than PromQL/LogQL for our workloads, and lock-in that makes the next cloud migration a rewrite.

---

## 7. Network Observability

**Business problem:** "It's the network" is the most common and least visible root cause. For AI infra
the fabric *is* the bottleneck.

| Signal | Chosen tool | Alternatives | Why chosen |
|---|---|---|---|
| Flow / L3-L4 | **Cilium + Hubble** (eBPF) | NetFlow/sFlow, cloud flow logs, packet capture | eBPF flow + identity-aware, no taps/sidecars |
| L7 (HTTP/gRPC/DNS) | **Hubble + Beyla** | Service mesh (Envoy stats) | eBPF L7 visibility incl. DNS latency |
| Metrics | **hubble metrics + node net counters → Prometheus** | SNMP, vendor | Prometheus-native, joins the same plane |
| Logs | **Hubble flow logs → Loki** (sampled) | Full flow logs to ELK | Flow logs are huge; sample + label-index |
| DNS | **CoreDNS metrics + Hubble DNS** | dedicated DNS monitors | DNS latency is the silent p99 killer; first-class |
| AI fabric | **RDMA/InfiniBand counters + NCCL metrics → Prometheus** | vendor fabric managers | (see §11) |
| Dashboards/Alerts | **Grafana / Alertmanager** | — | retransmits, RTT, DNS p99, policy drops |

**Design decisions & trade-offs**
- **The N² cardinality problem of service-to-service edges.** Per-edge golden signals across thousands
  of services is combinatorial. Decision: aggregate to *service-identity* edges (Cilium identities),
  not per-pod, and cap/topk the long tail.
- **eBPF flow over packet capture** because full pcap at line rate is infeasible and privacy-fraught;
  eBPF gives flow + L7 metadata at a fraction of the cost.

---

## 8. Application Observability

**Business problem:** 2,000+ polyglot services — sync REST/gRPC/GraphQL plus Kafka-driven async
pipelines. We need RED (Rate/Errors/Duration) everywhere and async-lag visibility, with correlation
across signals.

| Signal | Chosen tool | Alternatives | Why chosen |
|---|---|---|---|
| Metrics | **OTel SDK / Micrometer → Prometheus → Mimir** | StatsD, vendor SDK | RED metrics + exemplars (links a metric spike to a trace) |
| Logs | **OTel structured logs / Alloy → Loki** (+ ClickHouse for wide events) | Log4j→ELK | Structured, trace-correlated (trace_id in every log line) |
| Traces | **OTel SDK + Beyla → Tempo** (tail-sampled) | Jaeger, vendor APM | End-to-end causality; Beyla covers un-instrumented legacy |
| Profiling | **Pyroscope** | Parca, language profilers | Code-level attribution, correlated from traces |
| Async (Kafka) | **kafka-lag-exporter / Burrow → Prometheus** | vendor | Consumer-lag is the canonical async SLI |
| Alerting | **Mimir rules + Sloth SLOs** | — | RED-based SLOs, burn-rate alerts |
| Dashboards | **Grafana RED dashboards per service** | — | standardized golden-signals template |

**Design decisions & trade-offs**
- **Exemplars are the killer correlation feature.** A Prometheus histogram bucket carries exemplar
  trace IDs, so a latency-spike panel in Grafana links directly to an exemplar trace in Tempo, which
  links to its logs in Loki and profile in Pyroscope. **This four-way correlation is the entire reason
  we mandate one Grafana plane** — it's impossible across vendor islands.
- **`trace_id` in every log line is mandatory** (enforced via the logging library standard). It's the
  glue between logs and traces.
- **GraphQL gets resolver-level spans** to expose the N+1 query problem that aggregate metrics hide.
- **Kafka consumer lag is an SLI, not a metric.** We define SLOs on end-to-end pipeline lag, not just
  service uptime, because an async system can be "100% up" and hours behind.

**Why OpenTelemetry SDK over vendor APM SDKs (Datadog tracer, New Relic agent):** same data, but OTel
keeps us backend-portable and is now the broadest-supported standard. Vendor agents are slightly more
turnkey and sometimes richer out-of-the-box, but the lock-in cost is unacceptable across 2,000
services.

---

## 9. API Observability

**Business problem:** Public and internal APIs with contractual SLAs. We must prove availability and
latency from the *user's* vantage point, not just server-side.

| Signal | Chosen tool | Alternatives | Why chosen |
|---|---|---|---|
| Synthetic (black-box) | **blackbox_exporter** (HTTP/TCP/DNS/ICMP) | Pingdom, Datadog Synthetics, Checkly | OSS, Prometheus-native probe metrics |
| Synthetic (multi-step) | **k6** (scripted journeys, scheduled) | Datadog browser tests, Postman monitors | Scriptable business-transaction flows, OSS |
| Real traffic (RUM) | **Grafana Faro** (web RUM → OTLP) | Datadog RUM, New Relic Browser | OSS, OTLP-native, joins the same plane |
| Metrics | **Prometheus** (probe + server RED) | — | availability, latency, rate-limit, auth-fail rates |
| Traces | **Tempo** (server-side) | — | dependency mapping from real traces |
| SLA/SLO | **Sloth/Pyrra** + recording rules | Nobl9 | contractual SLA reporting from SLI data |
| Dashboards/Alerts | **Grafana / Alertmanager** | — | multi-region probe heatmap, SLA burn |

**Design decisions & trade-offs**
- **Synthetic + RUM are complementary, not either/or.** Synthetics catch outages on unused paths and
  give clean SLA numbers from fixed vantage points; RUM tells you what *real users* actually
  experience (their networks, devices, geographies). We run both.
- **Global probe placement** from multiple regions to distinguish "the API is down" from "one region's
  egress is down."
- **Dependency mapping comes from real traces (Tempo service graph)**, not a hand-drawn diagram that's
  always stale.

---

## 10. LLM & Agentic AI Observability

**Business problem:** This is the frontier and the differentiator. LLM and agent systems fail in ways
classic observability is blind to: a request can be **200 OK, fast, and completely wrong/hallucinated/
unsafe**. Cost per request varies 100× by token count. Agents loop, call tools, and fan out
unpredictably. We need **semantic + economic + quality** observability layered on top of normal infra
signals.

| Signal | Chosen tool | Alternatives | Why chosen |
|---|---|---|---|
| Tracing (LLM/agent spans) | **OpenTelemetry GenAI semantic conventions + OpenLLMetry (Traceloop) → Tempo** | LangSmith (SaaS), Langfuse, Arize Phoenix | OTel GenAI conventions are the emerging standard; vendor-neutral spans for prompt/completion/tool calls |
| LLM eval / quality | **Langfuse** (OSS, self-host) or **Arize Phoenix** (OSS) | LangSmith, Braintrust, HoneyHive | Self-hostable; traces + evals + datasets; OTLP-compatible |
| Metrics | **OTel metrics → Prometheus → Mimir** | vendor dashboards | tokens/req, TTFT, inter-token latency, cost/req, tool-call counts |
| Logs (prompt/response) | **Loki (sampled) + ClickHouse (wide events)** | vendor | full prompt/response capture is huge + PII-sensitive → sampled, redacted, wide-event in ClickHouse |
| Quality scoring | **LLM-as-judge + human feedback → metrics** | — | no ground truth in prod; proxy quality signals |
| Dashboards/Alerts | **Grafana** + Langfuse UI | — | cost burn, quality drift, latency, error/refusal rate |

**The LLM-specific signals that matter (and have no classic analog):**
- **Token economics:** input/output tokens per request, **\$/request**, \$/user, \$/feature. Token
  count is the cost driver and it's invisible to HTTP metrics. This is the #1 thing finance asks for.
- **Latency decomposed:** **TTFT (time-to-first-token)** vs **inter-token latency** vs total. Users
  feel TTFT; classic "request duration" hides it entirely.
- **Quality without ground truth:** hallucination rate, **LLM-as-judge** scores, retrieval relevance
  (for RAG), refusal/safety-trigger rate, user thumbs-up/down. These are *proxy* signals and we treat
  them as SLIs.
- **Agentic-specific:** tool-call success/failure, **agent loop depth / step count** (runaway-loop
  detection — an agent stuck in a loop burns money fast), inter-agent message traces, plan/replan
  events. An agent trace is a *tree*, and Tempo/TraceQL visualizes it natively.
- **Drift:** prompt drift, embedding drift, output-distribution drift (overlaps with §15 MLOps).

**Design decisions & trade-offs**
- **OTel GenAI conventions over a proprietary LLM-observability SaaS** so LLM telemetry lives in the
  *same* Tempo/Grafana plane as the infra serving it — you can pivot from "this request was slow" to
  "the GPU node it ran on was throttling" in one click. A siloed LLM-eval SaaS can't do that.
- **Langfuse/Phoenix for the eval+dataset layer** (which Tempo doesn't do) but wired via OTLP so it's
  additive, not a separate island. Langfuse runs locally — great for your labs.
- **Prompt/response capture is sampled and PII-redacted at the agent tier.** Full capture of every
  prompt is a storage and a privacy/compliance bomb. We sample (keep 100% of errors/low-quality), and
  redact at the OTel Collector before storage.
- **Cost attribution is non-negotiable at this layer** — token→dollar conversion is a Collector
  processor that tags every span with computed cost, so \$/feature dashboards come for free.

**Why not LangSmith (the obvious default):** excellent DX and the LangChain-native choice — but it's
SaaS, it's a silo from your infra telemetry, and it doesn't self-host for local labs. We use OTel +
Langfuse to stay unified and OSS.

---

## 11. AI Infrastructure (GPU) Observability

**Business problem:** GPU clusters cost tens of millions; an idle or stalled GPU is the most expensive
failure in the company. Distributed training jobs spanning thousands of GPUs die if *one* GPU faults.
We observe **utilization, interconnect, and goodput** at \$/GPU-hour granularity.

| Signal | Chosen tool | Alternatives | Why chosen |
|---|---|---|---|
| GPU metrics | **NVIDIA DCGM-exporter → Prometheus → Mimir** | nvidia-smi scraping, Bright, vendor | DCGM is the authoritative GPU telemetry source; Prometheus-native exporter |
| Interconnect | **DCGM NVLink + RDMA/InfiniBand counters + NCCL → Prometheus** | fabric-manager UIs | Joins fabric health to the same plane |
| Training metrics | **OTel/Prometheus from framework (PyTorch/Megatron) → Mimir** | TensorBoard, W&B | step time, MFU, tokens/sec, loss — in the same plane as infra |
| Inference metrics | **vLLM/TGI/TensorRT-LLM metrics → Prometheus** | vendor | KV-cache, batch efficiency, TTFT, queue depth |
| Logs | **Job/pod logs → Loki**; NCCL debug → ClickHouse | — | straggler/XID error forensics |
| Profiling | **Pyroscope (CPU) + Nsight/CUDA (GPU kernels, on-demand)** | — | host-side continuous + GPU kernel deep-dives |
| Alerts/Dashboards | **Grafana / Alertmanager** | DCGM dashboards | XID errors, ECC, thermal throttle, MFU drop, GPU-down |

**The GPU signals that matter (and the traps):**
- **"GPU utilization %" lies.** DCGM's `GPU_UTIL` only says a kernel was running, not that the GPU was
  *busy*. The real signals are **SM occupancy**, **tensor-core utilization**, and **HBM memory
  bandwidth utilization**. A job can show 100% "util" at 15% MFU. We dashboard **MFU (Model FLOPs
  Utilization)** as the true goodput metric.
- **XID errors and ECC** are the early-warning of hardware failure; we alert on them before the GPU
  dies and kills a training run.
- **Thermal/power throttling** silently caps performance; throttle events are first-class.
- **NCCL all-reduce tail latency** — in distributed training the slowest GPU (straggler) gates the
  whole step. Straggler detection is a flagship dashboard.
- **Checkpoint duration/failure** — checkpointing a giant model stalls training; failed checkpoints
  risk losing days of compute.

**Design decisions & trade-offs**
- **DCGM-exporter is non-negotiable** — it's NVIDIA's own telemetry and the only authoritative source.
  Everything else (nvidia-smi scraping) is a strictly worse subset.
- **Infra signals and ML-framework signals must be joined.** "GPU is hot" + "MFU dropped" + "NCCL
  latency spiked" together tell the story; separately they're noise. One Mimir/Grafana plane makes the
  join trivial.
- **Per-job + per-GPU cost attribution** (\$/GPU-hour × utilization) drives the most important
  conversation in the company: which teams waste GPUs.
- **GPU kernel profiling (Nsight) is on-demand, not continuous** — it's too heavy for always-on, so
  Pyroscope runs continuously on the host side and Nsight is triggered for deep-dives.

---

## 12. Security Observability

**Business problem:** Security and observability draw from the same telemetry; we serve SRE *and*
SecOps from shared pipelines without duplicating ingestion, while meeting compliance (SOC2/PCI/
FedRAMP) immutability requirements.

| Signal | Chosen tool | Alternatives | Why chosen |
|---|---|---|---|
| Runtime threat detection | **Falco** (+ **Tetragon**, eBPF) | Sysdig (commercial), Aqua | OSS runtime detection; Tetragon adds eBPF enforcement |
| Audit logs | **K8s audit + cloud activity → Loki/ClickHouse → SIEM** | direct-to-SIEM | Keep a queryable copy in-plane; forward to SIEM |
| Network policy | **Cilium/Hubble** policy-drop visibility | Calico | Already deployed; shows denied flows |
| Identity/secrets | **cert/secret expiry exporters → Prometheus** | manual | Cert expiry = recurring outage cause; alert ahead |
| SIEM | **Azure Sentinel / Splunk ES** (integration, not replacement) | Elastic SIEM | Meet mandates; we feed it, don't host on it |
| Compliance logs | **Immutable object storage (WORM) + ClickHouse** | Splunk | tamper-evident, cheap long retention |
| Dashboards/Alerts | **Grafana + SIEM** | — | audit anomalies, policy drops, cert expiry |

**Design decisions & trade-offs**
- **One pipeline, two consumers.** The OTel/Kafka backbone forks: a copy to the observability stores,
  a copy to the SIEM. We don't run two collection fleets.
- **Cert/secret expiry monitoring is boring and saves you constantly** — expired certs are a top
  cause of self-inflicted outages. A simple exporter + 30/14/7-day alerts pays for itself.
- **Falco (detection) + Tetragon (eBPF, can enforce)** are complementary; Falco's rule ecosystem is
  mature, Tetragon's eBPF gives lower overhead and enforcement.
- **WORM object storage for compliance logs** — immutability/legal-hold is a *storage* property; we
  satisfy it cheaply in Blob with object-lock rather than paying Splunk retention rates.

**Why integrate with Splunk/Sentinel instead of replacing them:** SIEM is often a *compliance and
SecOps-team* mandate with its own correlation rules and analysts. We don't fight that — we feed it
efficiently and keep a cheaper queryable copy in-plane for engineers.

---

## 13. Cross-cutting Concerns

### Alerting & SLOs (the operating discipline)
- **Engine:** Prometheus/Mimir evaluate rules; **Alertmanager** routes/dedups/silences/groups; routes
  to PagerDuty/Slack/Teams. **Grafana Alerting** is the unified authoring UI on top.
- **SLOs:** defined as code with **Sloth/Pyrra**, which generate **multi-window, multi-burn-rate**
  alerts (Google SRE workbook method) — fast-burn pages, slow-burn tickets. We alert on **symptoms
  (SLO burn), not causes**, to kill alert fatigue. Every page must be actionable or it gets deleted.
- **Meta-monitoring:** a separate, smaller Prometheus + Alertmanager pair watches the platform itself
  (Mimir ingesters, Loki, Tempo, Collector queues), so the observability platform never goes blind to
  its own failure. Dead-man's-switch alert confirms the alerting path is alive.

### Multi-tenancy & governance
- **Mimir/Loki/Tempo are natively multi-tenant** (per-tenant limits, isolation). Each team is a
  tenant with **cardinality/ingestion quotas** enforced at the gateway.
- **Cardinality budgets per team** with chargeback/showback. Exceed your budget → your high-cardinality
  series get dropped (with a loud alert to *you*), not the platform's stability sacrificed.
- **GitOps everything:** dashboards (Grafonnet/provisioning), alert rules, Collector configs, scrape
  configs. Reviewable, revertible, no click-ops.

### Cost model (the senior-staff differentiator)
- **Unit economics tracked continuously:** \$/active-series (Mimir), \$/GB-ingested & \$/GB-scanned
  (Loki/ClickHouse), \$/trace (Tempo), \$/GPU-hour, \$/LLM-request. These are dashboards, not
  spreadsheets.
- **The tiering strategy is the cost strategy:** hot (recent, fast, expensive) → warm → cold (object
  storage, cheap, slower). Mimir/Loki/Tempo all tier to object storage by design.
- **The build-vs-buy crossover** is computed per signal. Rough industry crossover: SaaS wins below
  ~\$1–2M/yr of telemetry spend; self-hosted OSS wins above, *if* you have a platform team (~3–8
  engineers) — which at our scale we do. We document this so the decision is defensible, not dogmatic.

### Disaster recovery for the platform itself
- Object-storage backends replicated cross-region; Mimir/Loki/Tempo are stateless-compute over durable
  object storage, so a region loss is a re-deploy, not a data loss.
- **RPO/RTO defined for the telemetry platform** like any tier-1 service. During an incident the
  observability platform is the *most* critical service — if it's down, you're flying blind in a storm.

---

## 14. Build the Whole Thing Locally

You can run a faithful single-node slice of this entire platform on your Mac. The OSS choices were
made partly *so that you can*. Recommended progression for the labs:

**Tier 0 — the LGTM+P core (docker-compose):**
- **Grafana** (visualization + alerting)
- **Mimir** (or Prometheus alone first, then add Mimir) + **MinIO** (S3-compatible object storage)
- **Loki** + **Tempo** + **Pyroscope**
- **OTel Collector** (agent + gateway configs) — practice tail-sampling and PII redaction here
- A demo app emitting all signals (the OpenTelemetry Demo / "Astronomy Shop" is purpose-built and
  exercises metrics+logs+traces+profiles end to end)
- *Quickest start:* the official **`grafana/otel-lgtm`** all-in-one image gives you Grafana+Mimir+
  Loki+Tempo+Pyroscope in one container to learn against, then graduate to a real compose file with
  separate services so you can break and scale them.

**Tier 1 — Kubernetes (kind / minikube):**
- **kube-prometheus-stack** (Prometheus Operator + Grafana + Alertmanager + node_exporter +
  kube-state-metrics)
- **Loki + Alloy** DaemonSet, **Tempo**, **Pyroscope**
- **Cilium + Hubble** as the CNI (eBPF network observability)
- **OpenTelemetry Operator** for auto-instrumentation

**Tier 2 — the frontier (where budget meets reality):**
- **LLM/Agentic:** run **Langfuse** (docker-compose) + a small local model (Ollama) or a cheap API,
  instrument an agent with **OpenLLMetry**, export traces to Tempo *and* Langfuse. Build the
  token-cost + TTFT + quality dashboards. **Fully local, ~\$0.**
- **GPU:** you can't run a cluster on \$150/mo. Run **DCGM-exporter** against a short Azure **spot**
  T4 GPU VM to capture *real* DCGM signals for 2–4 hours, then **simulate cluster scale** with a
  synthetic DCGM metrics generator + `avalanche` for cardinality. Real signals, simulated scale.

**Tier 3 — Azure-specific (spot + teardown):**
- Diagnostic Settings → Event Hub → OTel Collector → Loki (the Azure log-tap pattern)
- Azure Monitor data source in Grafana for platform-only metrics
- **Always `terraform destroy` after each lab.** Lab 0 (cost guardrails) comes first.

**Scale-learning technique for all tiers:** you don't need real hyperscale to learn its failure
physics. Drive small components into their failure modes with **synthetic load** (`avalanche` for
metric cardinality, `k6`/`vegeta` for request load, log generators for ingest pressure), observe the
*identical* failure, then compute the capacity/cost math for 1000×. That's the honest bridge — real
texture, real reasoning, small bill.

---

## 15. One-glance decision summary

| Domain | Metrics | Logs | Traces | Profiling | Network | Special |
|---|---|---|---|---|---|---|
| **Core stack** | Prometheus→Mimir | Loki + ClickHouse | Tempo | Pyroscope | Cilium/Hubble | OTel Collector, Grafana, Alertmanager, Kafka |
| **Infra/Linux** | node_exporter | journald→Loki | — | Pyroscope eBPF | host counters | PSI over loadavg |
| **Kubernetes** | kube-prometheus→Mimir | Alloy→Loki | OTel→Tempo | Pyroscope | Cilium/Hubble | etcd fsync, APF, autoscaler conflicts |
| **Azure** | Azure Monitor→Mimir | DiagSettings→EventHub→Loki | App Insights+Tempo | — | — | Event Hub backbone, DCR cost control |
| **Network** | hubble→Prom | Hubble flows→Loki | — | — | Cilium/Hubble | DNS p99, N² edge cardinality |
| **Application** | OTel→Mimir | OTel→Loki/ClickHouse | OTel+Beyla→Tempo | Pyroscope | — | exemplars, trace_id in logs, Kafka lag SLI |
| **API** | blackbox+RED | — | Tempo (svc graph) | — | — | k6 multi-step, Faro RUM, SLA reporting |
| **LLM/Agentic** | OTel→Mimir | Loki/ClickHouse (sampled) | OTel GenAI→Tempo + Langfuse | — | — | tokens/$, TTFT, LLM-as-judge, loop depth |
| **GPU/AI-infra** | DCGM→Mimir | Loki/ClickHouse | — | Pyroscope + Nsight | RDMA/IB/NCCL | MFU truth, XID/ECC, straggler detection |
| **Security** | cert/secret expiry | audit→ClickHouse/SIEM | — | — | Hubble policy drops | Falco+Tetragon, WORM compliance |

---

### Closing note from the architect

The hard part of this platform was never picking tools — it was **deciding once and holding the line**:
one instrumentation standard (OpenTelemetry), one visualization plane (Grafana), cheap-by-default
storage, governed cardinality, and honest sampling. Every tool above is replaceable; the *principles*
and the *correlation across one plane* are what make it a platform instead of a pile of dashboards.
Build the local slice in §14, break each component on purpose, and you'll understand not just what we
chose, but why every alternative loses at scale.

*Companion docs to build next: per-domain deep-dives in their numbered folders, each following the
25-point `LEARNING-STRUCTURE.md`. This document is the map; those are the territory.*
