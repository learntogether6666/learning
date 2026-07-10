# General workload pool — every future stack component (Grafana, Loki, Tempo,
# Prometheus/Mimir, OTel Collector, simulated-DCGM DaemonSet, simulated
# training/inference test pods) lands here until there's a concrete reason to
# split further (e.g. a real GPU pool once T4 quota is approved).
resource "azurerm_kubernetes_cluster_node_pool" "general" {
  name                  = "general"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.general_vm_size
  mode                  = "User"
  os_disk_size_gb       = 30
  vnet_subnet_id        = azurerm_subnet.aks_nodes.id

  # Regular (on-demand) priority — Spot capacity for both Standard_B2s and
  # Standard_D2s_v3 hit SkuNotAvailable in eastus at cluster-creation time
  # (genuine capacity pressure, not a SKU-specific fluke). Cost impact is
  # small since the cluster is stopped between sessions (az aks stop); revisit
  # Spot later if capacity frees up.
  priority = "Regular"

  auto_scaling_enabled = true
  min_count            = var.general_min_count
  max_count            = var.general_max_count

  node_labels = {
    "workload-type" = "general"
  }

  tags = var.tags
}
