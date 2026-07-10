resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.dns_prefix

  # Free tier: $0 control plane, no SLA — correct for a lab.
  sku_tier = "Free"

  # No pin, no auto-upgrade channel: avoids surprise version bumps between sessions.
  # Bump manually via var changes when ready.

  identity {
    type = "SystemAssigned"
  }

  # System-only pool: CoreDNS/metrics-server/konnectivity live here, nothing else.
  # only_critical_addons_enabled taints this pool so workload pods land on the
  # "general" pool (azurerm_kubernetes_cluster_node_pool.general) instead.
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_vm_size
    node_count                   = 1
    os_disk_size_gb              = 30
    vnet_subnet_id               = azurerm_subnet.aks_nodes.id
    only_critical_addons_enabled = true
    tags                         = var.tags
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "azure"
    pod_cidr            = var.pod_cidr
    load_balancer_sku   = "standard"
  }

  # Azure Monitor / Container Insights add-on deliberately NOT enabled here —
  # it bills Log Analytics per GB ingested. The observability stack will be
  # self-hosted OSS, added one component at a time in later sessions.

  tags = var.tags
}
