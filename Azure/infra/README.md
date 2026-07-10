# Azure/infra — Azure Resource Management (OpenTofu)

Infra-as-code for all Azure resources in this repo's labs. Kept separate from
`AI-Infra/Labs/` (which holds the written lab docs/architecture/runbooks) because
this cluster is shared, long-lived infrastructure that future labs build on
incrementally — not a one-off lab artifact.

Tooling: **OpenTofu** (not HashiCorp Terraform — Terraform is BSL-licensed as of
v1.5.0, not OSI open source; OpenTofu is the MPL-2.0 Linux Foundation fork, fully
drop-in compatible). Binary lives at `C:\bin\tofu.exe` (installed via `winget
install OpenTofu.Tofu`).

## Layout

- `bootstrap/` — one-time setup: `rg-tofu-state` resource group + storage account
  (`sttofuaksvsr01`) + blob container (`tofustate`) that hold OpenTofu's **remote
  state**. Uses local state itself (rarely changes, doesn't need to be shared).
- `aks-cluster/` — the AKS cluster (`rg-aks-observability-lab` /
  `aks-observability-lab`, `eastus`). Uses the remote backend from `bootstrap/`.

## Quick reference

```bash
# Any config folder:
cd Azure/infra/<bootstrap|aks-cluster>
tofu init
tofu plan -out=plan.tfplan     # review before applying — real billed resources
tofu apply plan.tfplan

# Get cluster credentials (from aks-cluster/):
az aks get-credentials -g rg-aks-observability-lab -n aks-observability-lab

# Cost control — stop/start, NOT destroy/recreate, between sessions:
az aks stop  -g rg-aks-observability-lab -n aks-observability-lab
az aks start -g rg-aks-observability-lab -n aks-observability-lab

# End of the lab series only:
cd Azure/infra/aks-cluster && tofu destroy
cd Azure/infra/bootstrap    && tofu destroy   # last, once nothing needs remote state
```

## Second-laptop setup

1. `az login` (subscription `0a5a25eb-e88c-4dd3-9b6e-cd71db042088`, Visual Studio
   Enterprise — verify with `az account show`, `az account set --subscription
   0a5a25eb-e88c-4dd3-9b6e-cd71db042088` if the wrong one is default).
2. Install OpenTofu (`winget install OpenTofu.Tofu`).
3. `cd Azure/infra/aks-cluster && tofu init` — pulls existing remote state, no
   need to re-run `bootstrap/` (already exists in Azure).

## Cost guardrails baked into `aks-cluster/`

- AKS **Free tier** control plane ($0).
- System pool (`Standard_B2s`, on-demand, 1 node) tainted `only_critical_addons`
  so nothing but system pods can schedule there.
- General pool (`Standard_B2s`, **Spot**, autoscaled 1-3) is where all workload
  stack pieces land.
- **No Azure Monitor / Container Insights add-on** — avoids per-GB Log Analytics
  billing; observability stack is self-hosted OSS instead, added incrementally.
- See `AI-Infra/Labs/AKS-Lab-01.md` for the full architecture writeup, node-pool
  taxonomy for future workloads (training/inference/GPU-sim), and cost model.
