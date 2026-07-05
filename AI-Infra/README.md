# AI-Infra — Hyperscale AI Infrastructure (a 9-Level Course)

> **What this is:** a graduate-level course on how to **design and operate Physical AI
> supercomputers** at the scale of OpenAI / Meta / Google DeepMind / Microsoft Azure AI — not just
> "how to train a model." NVIDIA-only compute, 2-trillion-parameter training, and real-time inference
> as the twin goals.
>
> **How to read it:** like building a city. You don't start with highways — you start with one house.
> We begin at a **single GPU** and zoom out one ring at a time until we reach a **gigawatt-scale
> datacenter campus**. Each level assumes the one before it.

## The teaching style (every level follows it)

Intuition + analogy first → a diagram that builds up → **then** the hyperscale depth (real numbers,
worked math, trade-offs) → failure modes → interview deep-dives → a bridge to the next level. The goal
is that you can *explain it to someone else* and *defend it in a Principal-level interview*.

## The 9 Levels

```
Level 1  GPU Architecture            ─┐
Level 2  Single GPU Server            │
Level 3  Multi-GPU Server (NVLink)    │  Foundations/  (the house → the building)
Level 4  Rack Design                  │
Level 5  Network Fabric (InfiniBand)  │
Level 6  Storage & Data Pipeline     ─┘
Level 7  Distributed Training        ─┐
Level 8  The AI Supercomputer         │  Production/   (the city → operating it)
Level 9  Physical AI Infrastructure  ─┘
```

### `Foundations/` — building the machine
| Level | File | The question it answers |
|---|---|---|
| 1 | [`Level-1-GPU-Architecture.md`](Foundations/Level-1-GPU-Architecture.md) | Why is a GPU shaped the way it is, and why is "100% util" a lie? |
| 2 | [`Level-2-Single-GPU-Server.md`](Foundations/Level-2-Single-GPU-Server.md) | How does a server feed and orchestrate a GPU? (CPU, PCIe, NIC, the CUDA stack) |
| 3 | [`Level-3-Multi-GPU-Server.md`](Foundations/Level-3-Multi-GPU-Server.md) | How do 8 GPUs act like one? (NVLink / NVSwitch) |
| 4 | [`Level-4-Rack-Design.md`](Foundations/Level-4-Rack-Design.md) | Why do power and heat — not space — limit a rack? |
| 5 | [`Level-5-Network-Fabric.md`](Foundations/Level-5-Network-Fabric.md) | How do thousands of GPUs synchronize as one computer? (InfiniBand / RDMA / SHARP) |
| 6 | [`Level-6-Storage-and-Data-Pipeline.md`](Foundations/Level-6-Storage-and-Data-Pipeline.md) | How do you feed the beast without starving it? |

### `Production/` — operating the machine
| Level | File | The question it answers |
|---|---|---|
| 7 | [`Level-7-Distributed-Training.md`](Production/Level-7-Distributed-Training.md) | How does one 2T-param job run in lockstep across 10,000 GPUs? (parallelism, collectives, the memory math, MFU/goodput) |
| 8 | [`Level-8-AI-Supercomputer.md`](Production/Level-8-AI-Supercomputer.md) | How do you operate training + **real-time inference** across regions, and survive constant failure? |
| 9 | [`Level-9-Physical-AI-Infrastructure.md`](Production/Level-9-Physical-AI-Infrastructure.md) | The datacenter as a machine: power/cooling/grid, the org, and the economics ($/token, $/GPU-hour). |

## The one idea the whole course returns to

> A hyperscale AI cluster is **one computer** whose instruction set is **collective communication**
> (all-reduce / all-gather / all-to-all), and whose true scorecard is **goodput** (useful FLOPs net of
> failures, stragglers, congestion, and checkpointing) and **$/token** — never "GPU utilization %".

Every level feeds that scorecard: SM/Tensor-Core efficiency (L1), the server/stack that launches work
(L2), NVLink for tensor parallelism (L3), power/heat ceilings (L4), the fabric that carries collectives
(L5), the storage that keeps GPUs fed (L6), the parallelism + collectives that define the job (L7), the
scheduling + inference + reliability that operate it (L8), and the power + org + economics that make it
real (L9).

## Cross-references

- `Observability/14-AI Infrastructure Observability/` — telemetry for everything here (DCGM, MFU/goodput, NVLink/IB congestion, KV-cache & batching SLOs).
- `Observability/15-MLOps Observability/` — drift/quality closed loop above the infra.
- `Observability/18-Architecture Patterns/00-Reference-Platform-Architecture.md` — the platform answer-key.

## Status / next

The 9 levels are the core curriculum. **Next candidates:** per-level **labs** (local-first: kind +
DCGM exporter + a tiny vLLM serve to reproduce KV-cache pressure, continuous batching, and a simulated
straggler → goodput collapse at small scale), an **inference-engine tool-decision arena** (vLLM vs
TensorRT-LLM vs SGLang), and a **cost model** ($/token, $/training-run, MW capacity). See
`Observability/00-Roadmap/STATUS.md` for the live position.
