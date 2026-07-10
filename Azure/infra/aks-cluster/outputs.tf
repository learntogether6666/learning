output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "node_resource_group" {
  description = "Azure-managed resource group holding the actual VMs/disks/LBs (MC_*)"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}
