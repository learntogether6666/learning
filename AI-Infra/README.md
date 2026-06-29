# AI-Infra — Hyperscale AI Infrastructure (Domain)

> **What this is:** a top-level domain (sibling to `Observability/`) for **building and operating**
> hyperscale AI infrastructure — GPU superclusters, training of 2T+ parameter models, and real-time
> inference serving — at the level of OpenAI / Meta / Google DeepMind / Microsoft Azure AI.
>
> **Distinct from `Observability/14-AI Infrastructure Observability/`:** that phase covers *observing*
> GPU infra. This domain covers *designing and running* it. The two cross-link, they don't duplicate.

## Scope (decided 2026-06-29)

NVIDIA-only compute; InfiniBand/NVLink/NVSwitch fabric; CUDA stack; twin centers of gravity —
**2T-parameter training** and **real-time inference serving**; production/hyperscale depth, no toy
examples; "added" components flagged where the source brief omitted them.

## Contents

| File | What it covers |
|---|---|
| [`01-Foundations/Section-1-AI-Infrastructure-Foundations.md`](01-Foundations/Section-1-AI-Infrastructure-Foundations.md) | **Deep tech stack:** GPU compute (H100/H200/GB200, SMs, Tensor Cores, HBM), CUDA stack (cuDNN/cuBLAS/NCCL/CUDA Graphs/Transformer Engine), NVLink/NVSwitch, InfiniBand RDMA + SHARP, storage (NVMe-oF/GDS/parallel FS), parallelism (DP/TP/PP/EP/ZeRO), the 2T memory math, FP8 stability, checkpoints. **+ added:** power/cooling, scheduling, collectives, economics. |
| [`02-Production-Stack/Section-2-LearnAI-Production-Stack.md`](02-Production-Stack/Section-2-LearnAI-Production-Stack.md) | **Production platform:** 4-region design, T/FT/I cluster types, model lifecycle + placement, adapter multiplexing, 2T operational scale, network integration, Microsoft-style team model, **real-time inference physics** (prefill/decode disaggregation, KV cache, batching, SLOs), failover/reliability + goodput math, observability control loop, economics. |

## The one idea both documents return to

> A hyperscale AI cluster is **one computer** whose instruction set is **collective communication**
> (all-reduce / all-gather / all-to-all) and whose real scorecard is **goodput** (useful FLOPs net of
> failures, stragglers, congestion, and checkpointing) and **$/token** — never "GPU utilization %".

## Cross-references

- `Observability/14-AI Infrastructure Observability/` — telemetry for everything here.
- `Observability/15-MLOps Observability/` — drift/quality closed loop.
- `Observability/18-Architecture Patterns/00-Reference-Platform-Architecture.md` — the answer key.

## Status / next

Section 1 + 2 drafted (production-grade reference docs). **Next candidates:** per-section labs
(local-first: a kind cluster + DCGM exporter + a tiny vLLM serve to reproduce KV-cache pressure and
continuous-batching behavior at small scale; a simulated straggler to show goodput collapse), a
tool-decision arena for inference engines (vLLM vs TRT-LLM vs SGLang), and interview-question banks.
See `Observability/00-Roadmap/STATUS.md` for the live position.
