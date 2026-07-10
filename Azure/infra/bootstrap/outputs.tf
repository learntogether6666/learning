output "resource_group_name" {
  value = azurerm_resource_group.tofu_state.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tofu_state.name
}

output "container_name" {
  value = azurerm_storage_container.tofu_state.name
}
