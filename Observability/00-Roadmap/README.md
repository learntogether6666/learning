# Observability Engineering — Master Roadmap

> **Goal:** Principal / Senior Staff Observability Engineer capable of designing and operating
> telemetry platforms handling **petabytes of logs, billions of active metric series, millions of
> traces/sec, and millions of API requests/sec** across Azure, Kubernetes, AI Infrastructure, MLOps,
> and enterprise distributed systems.
>
> **Audience assumption:** You already have strong infrastructure engineering experience. This
> roadmap skips beginner material and treats every topic at production / hyperscale.

This is the spine of the handbook. Each phase below maps to numbered folders in `Observability/`.
Later, sibling top-level folders (`Kubernetes/`, `AI-Infra/`, `MLOps/`) will go deeper on those
domains — this Observability track gives them their telemetry foundation first.

---

## How to read this roadmap

- **Phases are ordered by dependency, not by interest.** Do not jump to AI-infra observability before
  you can reason about cardinality, sampling, and storage economics — you'll cargo-cult dashboards
  instead of designing systems.
- **Every module follows the 25-point learning structure** (see `LEARNING-STRUCTURE.md`): business
  problem → architecture → request lifecycle → scaling → failure → cost → interview questions → lab →
  assignment.
- **Mental model to hold throughout:** observability is a *data engineering and economics problem
  wearing an SRE costume*. The hard parts are never "how do I install Prometheus" — they are
  cardinality control, sampling strategy, storage tiering, query fan-out, and cost per unit of
  insight. Keep returning to those four levers.

---

## The North-Star Mental Model

Before any phase, internalize the pipeline every telemetry system is a variation of:

```
            ┌──────────┐   ┌───────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
  SOURCE →  │ INSTRUMENT│ → │  COLLECT  │ → │ PROCESS  │ → │  STORE   │ → │  QUERY   │ → CONSUME
            │  (SDK,    │   │  (agent,  │   │ (enrich, │   │ (TSDB,   │   │ (PromQL, │   (dashboards,
            │   eBPF,   │   │  gateway, │   │  sample, │   │  index,  │   │  LogQL,  │    alerts,
            │   scrape) │   │  buffer)  │   │  route)  │   │  object) │   │  trace)  │    SLOs, AI)
            └──────────┘   └───────────┘   └──────────┘   └──────────┘   └──────────┘
                  │              │               │              │              │
              cardinality    backpressure    sampling/      tiering/       fan-out/
              & overhead     & durability    aggregation    retention      query cost
```

The six failure-mode levers (under each arrow) recur in **every** phase. When you study a new tool,
locate it on this pipeline and ask: which lever does it move, and at what cost?

The **three pillars (metrics, logs, traces)** are not the model — they are three *encodings* of the
same events. Modern practice (OpenTelemetry, wide events, exemplars) is collapsing them. Treat
"pillars" as legacy framing; treat the pipeline above as the real architecture.

---

## Phase Map (at a glance)

| Phase | Folder | Theme | Depends on |
|------:|--------|-------|-----------|
| 0 | 00-Roadmap | Orientation, mental models, learning method | — |
| 1 | 01-Observability Fundamentals | Signals, SLI/SLO/error budgets, OTel, cardinality, sampling | 0 |
| 2 | 02-Linux Observability | Kernel, CPU/NUMA, memory, /proc, cgroups, USE method | 1 |
| 3 | 03-Network Observability | TCP/IP, DNS, eBPF flows, RDMA/InfiniBand, service mesh data | 2 |
| 4 | 04-Storage Observability | Disk, filesystem, object storage, IO latency, durability signals | 2 |
| 5 | 10-Metrics | Prometheus/VictoriaMetrics/Thanos/Mimir, remote-write, long-term storage | 1,2 |
| 6 | 09-Logging | Petabyte logging, Loki/Elastic/ClickHouse, routing, tiering, compliance | 1,4 |
| 7 | 11-Tracing | OTel tracing, Tempo/Jaeger, tail sampling, context propagation, critical path | 1,5 |
| 8 | 12-Profiling | Continuous profiling, Pyroscope/Parca, flame graphs, GPU profiling | 2,7 |
| 9 | 13-eBPF | Kernel instrumentation, Pixie/Cilium/Hubble, zero-instrumentation telemetry | 2,3 |
| 10 | 05-Kubernetes Observability | Control plane, etcd, scheduler, autoscalers, GPU scheduling, mesh | 2,5,7 |
| 11 | 06-Azure Observability | Azure Monitor, Log Analytics, App Insights, Managed Prom/Grafana, AKS | 5,6,10 |
| 12 | 07-Application Observability | RED/USE, gRPC/GraphQL, Kafka, event-driven, RUM, business txns | 5,6,7 |
| 13 | 08-API Monitoring | Availability, latency, SLO/SLA, synthetic, multi-step, dependency mapping | 12 |
| 14 | 14-AI Infrastructure Observability | GPU/NVLink/RDMA/NCCL, inference (KV cache, batching), training, checkpoints | 2,3,5,10,12 |
| 15 | 15-MLOps Observability | Data/model/embedding/prompt drift, pipelines, Ray/Kubeflow/MLflow | 12,14 |
| 16 | 16-Security Observability | Audit logs, SIEM, identity, secrets/certs, threat detection, compliance | 6,9,10 |
| 17 | 17-SRE | SLO engineering, error budgets, alerting theory, on-call, incident command | 1,12,13 |
| 18 | 18-Architecture Patterns | Reference architectures, multi-tenancy, federation, cost models | all |
| 19 | 19 / 20 / 21 | Case studies, production incidents, capstone projects | all |
| 20 | 22-Interview Preparation | Principal-level system design + deep dives | all |

> **Cross-references:** Metrics (5) is intentionally pulled *before* Logging and Tracing because its
> cardinality/storage lessons are the cheapest place to learn the economics that govern all three.
> eBPF (9) sits before Kubernetes because modern K8s observability (Cilium/Hubble/Pixie) is
> eBPF-native.

---

## PHASE 0 — Orientation (this folder)

**Outcome:** You can articulate the observability problem space as a data + economics problem and
navigate the handbook.

- `README.md` (this file) — the master roadmap.
- `LEARNING-STRUCTURE.md` — the 25-point template every module uses.
- `MATURITY-MODEL.md` — self-assessment from "monitoring" to "hyperscale observability platform".
- `TOOL-DECISION-MATRIX.md` — the running comparison table (Prometheus vs VictoriaMetrics vs Datadog
  vs Splunk vs Elastic vs Azure Monitor vs CloudWatch vs GCP Operations), updated as you go.

**Deliverable:** Write your own one-page "Why observability fails at scale" essay covering the four
levers (cardinality, sampling, tiering, query fan-out). Revisit and grade it after Phase 18.

---

## PHASE 1 — Observability Fundamentals  → `01-Observability Fundamentals`

**Prerequisites:** Distributed systems basics, HTTP, basic statistics (percentiles, histograms).

**Why this phase exists:** Every expensive mistake at scale is a fundamentals mistake compounded by
volume. A wrong histogram bucket choice or an unbounded label is a $2M/year bill at hyperscale.

**Core topics**
1. Monitoring vs observability — the real distinction (known-unknowns vs unknown-unknowns; high-
   cardinality, high-dimensionality data; ability to ask new questions without redeploying).
2. The signals: metrics, logs, traces, **events**, **profiles** — and why "three pillars" is dated.
3. Wide structured events / canonical log lines (the Honeycomb thesis) vs pre-aggregated metrics.
4. **Cardinality** — the master variable. Active series math, label hygiene, the combinatorial trap.
5. **Statistics for observability** — why averages lie, percentiles, histograms (classic vs native/
   exponential), quantile estimation error, t-digest/DDSketch, Apdex.
6. **Sampling** — head vs tail vs adaptive; the representativeness vs cost tradeoff.
7. **SLI / SLO / SLA / error budgets** — definitions, the math, multi-window multi-burn-rate alerts.
8. **OpenTelemetry** — the data model (signals, resource, semantic conventions), SDK vs Collector,
   OTLP, why the industry standardized on it and what it killed (vendor lock-in on instrumentation).
9. Push vs pull, agent vs agentless, the collector/gateway pattern, backpressure & durability.
10. Cost models — $ per active series, per GB ingested, per GB scanned, per host; the unit economics
    of each vendor.

**Tool selection introduced here:** OpenTelemetry (and why it won over OpenCensus + OpenTracing).

**Project:** *Design the telemetry contract for a 2,000-service platform.* Define semantic
conventions, required labels, cardinality budgets per team, and a sampling policy. Output: an
"observability standards" RFC like the ones platform teams publish internally.

**Lab:** Stand up OTel Collector → Prometheus + Tempo + Loki locally; instrument a 3-service app;
deliberately blow up cardinality and watch memory; then fix it with relabeling.

**Architecture assignment:** Write the cardinality-budget governance model for a multi-tenant
platform (per-team quotas, enforcement, chargeback).

**Outcome:** You can defend instrumentation, sampling, and SLO decisions with numbers, not vibes.

---

## PHASE 2 — Linux Observability  → `02-Linux Observability`

**Why:** Every metric you'll ever trust bottoms out in kernel counters. You cannot debug a p99 spike,
a noisy neighbor, or a GPU host stall without reading `/proc`, cgroups, and scheduler signals.

**Core topics:** USE method (Utilization/Saturation/Errors); CPU (run queue, context switches, steal,
pressure stall information/PSI); memory (RSS vs WSS, page cache, reclaim, OOM, cgroup v2 memory.high/
max); **NUMA** (locality, `numastat`, why it matters for GPU/ML hosts); disk & IO (iostat, await,
queue depth); the `/proc` and `/sys` interfaces; cgroups v2 accounting; load average myths;
`perf`, `bpftrace`, `pidstat`; node_exporter / cAdvisor internals (what each metric actually reads).

**Tool selection:** node_exporter vs telegraf vs vector vs vendor agents; when eBPF replaces them.

**Project:** *Build the host-level golden-signals dashboard + alerts for a 50,000-node fleet* — and
solve the cardinality problem of per-core, per-device metrics at that scale.

**Lab:** Reproduce CPU steal, memory pressure (PSI), and IO saturation; capture each in metrics +
flame graph.

**Outcome:** Given any host metric you can state exactly which kernel counter produced it and its
failure semantics.

---

## PHASE 3 — Network Observability  → `03-Network Observability`

**Why:** At hyperscale, "the network" is the most common root cause and the hardest to see. For AI
infra, the network (RDMA/InfiniBand/NVLink) *is* the bottleneck.

**Core topics:** TCP/IP signals (retransmits, RTT, congestion window, SYN backlog), connection
tracking, DNS observability (the silent killer of latency), L4 vs L7 visibility, packet vs flow vs
log; **eBPF-based flow telemetry** (Cilium/Hubble); service mesh telemetry (Envoy stats, what mesh
gives you and its overhead); load balancer / Front Door / App Gateway metrics; and **AI fabric**:
RDMA, InfiniBand counters, NVLink, NCCL collective performance, congestion and tail latency in
all-reduce.

**Tool selection:** Hubble vs traditional NetFlow/sFlow vs cloud flow logs; packet capture vs eBPF.

**Project:** *Observability for a multi-region service mesh* — golden signals per service-to-service
edge without exploding cardinality (the N² problem).

**Outcome:** You can diagnose latency as app vs network vs DNS vs fabric, with evidence.

---

## PHASE 4 — Storage Observability  → `04-Storage Observability`

**Why:** Telemetry systems are themselves enormous storage systems; and storage is what you monitor
for everyone else. Both directions matter.

**Core topics:** Block vs file vs object; IO latency anatomy; durability/availability signals; write
amplification; compaction (LSM trees — critical because Prometheus TSDB, Loki, ClickHouse, Cassandra
all use them); object storage (S3/Azure Blob) as the universal telemetry cold tier — consistency,
throughput, request cost; capacity & growth forecasting.

**Project:** *Capacity & cost model for object-storage-backed long-term telemetry* (Thanos/Mimir/
Loki on Azure Blob).

**Outcome:** You can forecast storage growth and cost for a petabyte telemetry backend and reason
about compaction-driven performance cliffs.

---

## PHASE 5 — Metrics  → `10-Metrics`

**Why:** Metrics are the cheapest, densest signal and the economic model for everything else.

**Core topics:** Prometheus internals (TSDB head/WAL/blocks, scrape, PromQL execution, the
2-hour block + compaction lifecycle); **cardinality at scale** and how it kills Prometheus;
remote-write protocol; **the scaling solutions** — Thanos (sidecar/store/compactor/query fan-out),
Cortex/Mimir (microservices, blocks storage), **VictoriaMetrics** (the single-binary challenger);
recording & alerting rules; federation vs remote-write vs query-federation; native histograms;
exemplars (the metrics→traces bridge); downsampling & long-term storage; high-availability pairs &
deduplication.

**Tool selection (deep, this is a flagship comparison):**
Prometheus vs VictoriaMetrics vs Thanos vs Mimir/Cortex vs Datadog vs Azure Monitor Managed
Prometheus vs CloudWatch vs GCP Monitoring — on ingestion rate, active-series ceiling, query
performance, operational complexity, and **$ per million active series**.

**Project:** *Design a metrics platform for 1 billion active series, multi-region, 13-month
retention, 99.9% query availability.* Pick the stack and justify it on cost and ops load. Include
remote-write capacity planning, ingestion sharding, and query fan-out limits.

**Labs:** Thanos and VictoriaMetrics clusters; replay a cardinality explosion; tune remote-write;
build multi-burn-rate SLO alerts.

**Outcome:** You can architect and cost a hyperscale metrics platform and defend the build-vs-buy
decision.

---

## PHASE 6 — Logging  → `09-Logging`

**Why:** Logs are the most expensive and most abused signal. Petabyte logging is where budgets go to
die. Mastery here is a senior-staff differentiator.

**Core topics:** Collection (Fluent Bit/Fluentd/Vector/OTel) and the agent comparison; routing &
fan-out; parsing & enrichment at ingest vs query (schema-on-write vs schema-on-read); **index vs no-
index** — the Elasticsearch vs Loki vs ClickHouse philosophical split; hot/warm/cold/frozen tiering;
compression & columnar formats; retention & compliance (GDPR, PII, immutability, legal hold);
**sampling and quota enforcement for logs** (yes, you sample logs at scale); cost control patterns.

**Tool selection (flagship comparison):**
Elasticsearch/OpenSearch vs Grafana Loki vs ClickHouse vs Splunk vs Azure Log Analytics (KQL) vs
Datadog Logs vs CloudWatch Logs — on ingest cost, query model, index overhead, scale ceiling, and
the *fundamental tradeoff* (full-text index vs label index vs columnar scan).

**Project:** *Petabyte-per-day logging platform with 80% cost reduction mandate* — design tiering,
sampling, and a "logs as wide events in ClickHouse" migration off Elasticsearch. Include the
chargeback model.

**Outcome:** You can design a petabyte logging platform and aggressively defend its unit economics.

---

## PHASE 7 — Tracing  → `11-Tracing`

**Why:** Traces explain *causality* across services — the only signal that answers "where did the
time go" in a distributed request.

**Core topics:** OTel tracing data model; **context propagation** (W3C Trace Context, baggage, the
cross-language and cross-protocol problem); **sampling deep dive** — head vs tail vs adaptive, the
tail-sampling collector architecture and its statefulness/cost; storage backends (Tempo's object-
storage trace-by-ID model vs Jaeger+Cassandra/ES); **exemplars and trace↔metric↔log correlation**;
critical-path analysis; service dependency graphs; span metrics / RED-from-traces.

**Tool selection:** Jaeger vs Grafana Tempo vs Zipkin vs Datadog APM vs Honeycomb vs Azure App
Insights — sampling models, storage cost, query capability.

**Project:** *Tracing for 5M spans/sec with tail sampling that keeps 100% of errors and slow
requests at <2% retention cost.* Design the tail-sampling tier and its scaling/failure model.

**Outcome:** You can design a sampling strategy that is statistically defensible and economically
viable, and explain context propagation failures across polyglot stacks.

---

## PHASE 8 — Continuous Profiling  → `12-Profiling`

**Why:** Profiling closes the loop from "which request is slow" (traces) to "which line of code /
which allocation / which GPU kernel" — continuously, in production, at <1% overhead.

**Core topics:** Sampling profilers vs instrumentation; **eBPF-based whole-system profiling**
(Parca/Pyroscope/Grafana Phlare); CPU, memory/allocation, off-CPU, lock profiling; flame graphs &
differential flame graphs; **GPU profiling** (Nsight, CUDA, kernel-level) — the bridge to AI infra;
profile-to-trace correlation.

**Tool selection:** Pyroscope vs Parca vs Datadog Continuous Profiler vs Google Cloud Profiler.

**Project:** *Fleet-wide continuous profiling at <1% overhead for a 50k-host fleet*, with
differential profiling to catch regressions per deploy.

**Outcome:** You can deploy always-on profiling safely and use it to attribute cost/latency to code.

---

## PHASE 9 — eBPF  → `13-eBPF`

**Why:** eBPF is the biggest shift in observability in a decade — zero-instrumentation, kernel-level
visibility into network, security, and performance. It underpins modern K8s and AI-infra telemetry.

**Core topics:** eBPF execution model (verifier, maps, programs, hooks), overhead and safety;
**auto-instrumentation** of network/syscalls without code changes; Pixie (K8s app observability),
Cilium/Hubble (network + policy), BCC/bpftrace (ad-hoc), Tetragon (security); limits and gotchas
(kernel versions, verifier limits, CO-RE/BTF).

**Tool selection:** Pixie vs Hubble vs Cilium vs vendor eBPF agents (Datadog, Grafana Beyla).

**Project:** *Zero-instrumentation L7 golden signals for a polyglot K8s platform using eBPF* — and an
honest assessment of where eBPF is NOT enough (it doesn't know your business context).

**Outcome:** You can decide where eBPF replaces SDK instrumentation and where it can't.

---

## PHASE 10 — Kubernetes Observability  → `05-Kubernetes Observability`

**Why:** K8s is the substrate for everything else — and its control plane is a distributed system you
must observe to keep everything else alive.

**Core topics:** **Control plane signals** — API server (latency, inflight, etcd request rate),
scheduler (pending pods, scheduling latency), controller-manager, **etcd** (the most important and
most fragile component — db size, fsync latency, leader changes, compaction/defrag); kube-state-
metrics vs metrics-server vs cAdvisor; CNI/CSI/Ingress/Gateway API signals; **autoscaling
observability** (HPA, VPA, Cluster Autoscaler, KEDA — and why they fight each other); node problem
detection; **GPU scheduling & GPU Operator / DCGM exporter** (bridge to AI infra); service mesh at
K8s scale.

**Tool selection:** Prometheus Operator + kube-prometheus-stack vs Datadog K8s vs Azure Monitor for
Containers; DCGM exporter for GPU.

**Project:** *Observability for a 10,000-node, multi-tenant, GPU-enabled AKS fleet* — control-plane
SLOs, etcd health, GPU utilization, and per-tenant cost attribution.

**Outcome:** You can keep a hyperscale K8s control plane healthy and observable, including GPU nodes.

---

## PHASE 11 — Azure Observability  → `06-Azure Observability`

**Why:** This is your platform-of-record. You must master the native stack *and* know when to
replace it with OSS for cost/control.

**Core topics:** Azure Monitor architecture (Metrics + Logs/Log Analytics + KQL); Application
Insights (distributed tracing, the OTel-on-Azure story); **Azure Managed Prometheus + Managed
Grafana** (the managed-OSS path); the ingestion pipeline — **Event Hub / Service Bus / Event Grid**
as telemetry transport; AKS, Storage, Azure SQL, Cosmos DB, Redis, Front Door, App Gateway, Load
Balancer, Firewall, Private Link, DNS, ExpressRoute, Virtual WAN, Functions, Container Apps, VMSS,
Key Vault — what each emits and what to alert on; **DCR (Data Collection Rules)** and cost control;
KQL mastery.

**Tool selection (flagship):** Azure Monitor native vs Managed Prometheus/Grafana vs Datadog-on-
Azure vs self-hosted OSS — on cost, lock-in, query power, and multi-cloud portability.

**Project:** *Unified observability for a multi-region Azure + AKS platform* that balances Azure-
native (for managed services) with OSS Prometheus/Grafana (for K8s/app), with a single pane of glass
and a defensible cost model.

**Outcome:** You can architect observability for a large Azure estate and defend native-vs-OSS at
each layer.

---

## PHASE 12 — Application Observability  → `07-Application Observability`

**Core topics:** RED method (Rate/Errors/Duration) and USE for services; instrumenting REST, **gRPC**
(per-method, streaming, status codes), **GraphQL** (the resolver/N+1 visibility problem), message
queues & event-driven systems (**Kafka** consumer lag as the canonical async SLI, RabbitMQ, Azure
Service Bus); background jobs & batch; **Real User Monitoring (RUM)** and Core Web Vitals; business-
transaction & funnel observability; correlation across the three signals via trace/exemplar IDs.

**Project:** *End-to-end observability for an event-driven microservices platform* (sync APIs + Kafka
pipelines), including consumer-lag SLOs and exactly-once/duplicate visibility.

**Outcome:** You can instrument any application paradigm and tie technical signals to business KPIs.

---

## PHASE 13 — API Monitoring  → `08-API Monitoring`

**Core topics:** Availability vs latency vs correctness; **synthetic monitoring** (black-box, multi-
step transactions, global probe placement) vs RUM (real traffic); auth/rate-limit observability;
distributed API dependency mapping; **SLA vs SLO monitoring** and contractual reporting; multi-step
business-transaction monitoring; the blackbox_exporter and cloud synthetics.

**Project:** *Global synthetic + SLA platform for a public API* with multi-region probes, multi-step
flows, and automated SLA breach reporting.

**Outcome:** You can prove (and report on) external API SLAs with both synthetic and real signals.

---

## PHASE 14 — AI Infrastructure Observability  → `14-AI Infrastructure Observability`

**Why:** This is the frontier and the differentiator for an OpenAI/NVIDIA/Anthropic-level role. GPU
clusters cost \$10s of millions; idle or stalled GPUs are the most expensive failure in tech.

**Core topics**
- **GPU telemetry:** DCGM, utilization (and why "GPU util %" lies — SM occupancy vs memory bandwidth
  vs tensor-core util), HBM memory, power/thermals/throttling, ECC errors, XID errors.
- **Interconnect:** NVLink/NVSwitch, PCIe, **RDMA/InfiniBand**, NCCL collective performance, all-
  reduce tail latency, fabric congestion — the dominant bottleneck in distributed training.
- **Inference serving:** **KV-cache** utilization, **continuous batching** efficiency, **token
  throughput** (prefill vs decode), TTFT (time-to-first-token), inter-token latency, queueing, GPU-
  memory pressure, vLLM/TGI/TensorRT-LLM metrics.
- **Training:** step time, throughput (tokens/sec, samples/sec, MFU — model FLOPs utilization),
  gradient/loss curves, **checkpoint** duration & failure, stragglers, hardware-failure-induced
  restarts at scale (the "one of 10,000 GPUs failed and killed the job" problem).
- **Cluster health:** node/GPU failure detection, job scheduling (Slurm/Kubernetes+Kueue), capacity
  & utilization economics.

**Tool selection:** DCGM-exporter + Prometheus/Grafana vs NVIDIA Base Command / Bright vs vendor; the
gap between infra telemetry and ML-framework telemetry.

**Project:** *Observability for a 10,000-GPU training + inference cluster* — MFU and goodput
dashboards, straggler/failed-GPU detection, inference KV-cache & batching SLOs, and \$/token + \$/
training-run cost attribution.

**Outcome:** You can observe a GPU supercluster end to end and attribute cost and waste at the
\$/token and \$/GPU-hour level.

---

## PHASE 15 — MLOps Observability  → `15-MLOps Observability`

**Why:** Infra-healthy ≠ model-healthy. The model can degrade silently while every infra metric is
green. This is the layer above AI infra.

**Core topics:** **Drift** — data drift, feature drift, concept/model drift, **embedding drift**,
**prompt drift** (for LLM apps); inference quality monitoring (with no ground truth — proxy metrics,
LLM-as-judge, human feedback loops); training/experiment monitoring; pipeline observability;
**Ray / Kubeflow / MLflow** monitoring; feature-store observability; the closed loop from production
quality signals back to retraining triggers.

**Tool selection:** Evidently / Arize / WhyLabs / Fiddler vs DIY on the metrics stack; LLM-eval
tooling.

**Project:** *Production monitoring for an LLM platform* — drift, quality (LLM-as-judge + feedback),
hallucination/safety signals, cost-per-request, joined with the AI-infra layer from Phase 14.

**Outcome:** You can detect silent model degradation and tie ML quality to infra and cost signals.

---

## PHASE 16 — Security Observability  → `16-Security Observability`

**Core topics:** Audit logs (K8s audit, cloud activity logs) as a first-class signal; authn/authz/
RBAC observability; secrets & certificate expiry monitoring (the recurring outage cause); identity;
network policy visibility (Cilium/Tetragon); **SIEM integration** (Sentinel, Splunk ES) and the
observability↔security data overlap; threat detection signals; compliance monitoring (SOC2, PCI,
FedRAMP) and immutable/tamper-evident logging.

**Project:** *Security observability layer* feeding both the SRE platform and a SIEM, with cert-
expiry and audit-anomaly alerting.

**Outcome:** You can design telemetry that serves SRE and security from shared pipelines.

---

## PHASE 17 — SRE & Operating Practice  → `17-SRE`

**Why:** Tools without operating discipline produce dashboards nobody reads and alerts everybody
mutes. This phase is the human/process system around the data.

**Core topics:** SLO engineering in depth (target setting, error budgets, **multi-window multi-burn-
rate alerting** — the Google SRE workbook method); **alert design** (symptom vs cause, alert fatigue,
the "every alert is actionable" rule); on-call & escalation; **incident command** (severity, roles,
comms); blameless postmortems; **runbooks** as code; toil reduction; capacity planning as a
discipline; and **observability-driven AIOps** (anomaly detection, correlation, the honest limits of
ML-on-alerts).

**Project:** *SLO & alerting framework for a 2,000-service org* — the catalog, burn-rate alert
templates, routing, and an alert-quality scorecard.

**Outcome:** You can stand up the operating model, not just the telemetry plumbing.

---

## PHASE 18 — Architecture Patterns  → `18-Architecture Patterns`

**Why:** This is where you stop being a tool user and become a platform architect.

**Core topics:** Reference architectures for hyperscale telemetry; **multi-tenancy** (isolation,
quotas, noisy-neighbor, per-tenant cost); federation & global query; **build vs buy vs hybrid** at
each layer; the centralized-vs-decentralized platform-team model; the telemetry pipeline as a
streaming data platform (Kafka/Event Hub backbone, OTel Collector fleets, processing tiers); data
governance, PII, and retention as architecture; **cost as a first-class architectural constraint**
(unit economics, chargeback/showback, the "observability is 10–30% of infra spend" reality);
disaster recovery for the observability platform itself ("who watches the watchers").

**Capstone deliverable:** A complete **Observability Platform Design Doc** for a hypothetical
hyperscaler (petabytes of logs, 1B+ series, 5M traces/sec, multi-region Azure + GPU clusters):
requirements, SLAs/SLOs, architecture, tool selection with justification, capacity & cost model,
failure & DR plan, rollout strategy, and org/operating model.

**Outcome:** You can produce a Principal-level platform design doc end to end.

---

## PHASE 19 — Case Studies, Incidents, Projects  → `19` / `20` / `21`

- **19-Case Studies:** Reconstruct and critique real hyperscaler observability architectures (Uber's
  M3, Netflix's Atlas/Mantis, Cloudflare's logging, Grafana/Datadog/Honeycomb engineering, Meta's
  Scuba/ODS, LinkedIn's stack) — what they chose and *why*.
- **20-Production Incidents:** A library of post-incident analyses — cardinality explosions that
  took down Prometheus, etcd outages, sampling that hid an outage, a logging bill that 10×'d
  overnight, a cert expiry that blacked out a region. Each with timeline, root cause, and the
  observability gap that allowed it.
- **21-Projects:** The capstone projects from each phase, built and documented as portfolio pieces.

**Outcome:** You can reason from real failure, not just theory.

---

## PHASE 20 — Interview Preparation  → `22-Interview Preparation`

**Core topics:** Principal/Senior-Staff system-design interviews ("design Datadog", "design metrics
for 1B series", "design tracing for 5M spans/sec", "design GPU-cluster observability"); deep-dive
defense on cardinality, sampling, storage economics, and SLOs; the behavioral/leadership dimension
(driving platform adoption, cost wars, org influence); a bank of the hardest questions per phase.

**Outcome:** You can pass a Principal/Senior-Staff observability interview at a top-tier company.

---

## Cross-Cutting Threads (revisited in every phase)

These are not phases — they are lenses you apply continuously:

1. **Cardinality economics** — the single most important skill. Every phase has a cardinality angle.
2. **Sampling & aggregation** — what you keep vs drop, and how to stay statistically honest.
3. **Storage tiering & retention** — hot/warm/cold/object, and the cost cliffs.
4. **Cost / unit economics** — \$ per series, per GB, per scan, per token, per GPU-hour. Always.
5. **Failure modes & DR of the telemetry system itself.**
6. **OpenTelemetry as the convergence layer** across all signals.
7. **Build vs buy vs hybrid** — re-decided at every layer.

---

## Suggested Sequencing & Cadence

- **Foundations block (Phases 1–4):** fundamentals + the infra substrate. Do not rush — these pay
  compound interest.
- **Signals block (Phases 5–9):** metrics → logs → tracing → profiling → eBPF. The core craft.
- **Platform block (Phases 10–13):** K8s → Azure → app → API. Where signals meet real systems.
- **Frontier block (Phases 14–16):** AI infra → MLOps → security. The differentiators.
- **Mastery block (Phases 17–20):** SRE practice → architecture → case studies → interview.

Each phase = read/learn → build the lab → ship the project → write the architecture assignment →
answer the interview questions. **A phase is "done" only when the project is built and the design doc
is written** — not when the reading is finished.

---

## Definition of Done for the whole journey

You can walk into a room and design, cost, defend, and operate an observability platform for a
hyperscale, multi-region, Azure + Kubernetes + GPU environment handling petabytes of telemetry — and
explain every tool choice, failure mode, and dollar.

---

*Next files to create in this folder: `LEARNING-STRUCTURE.md`, `MATURITY-MODEL.md`,
`TOOL-DECISION-MATRIX.md`. Then begin Phase 1 in `01-Observability Fundamentals/`.*
