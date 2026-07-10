# VNet/subnet cost nothing by themselves — required because Azure CNI Overlay
# still attaches node NICs to a real VNet subnet, even though pods live in the
# separate overlay CIDR (var.pod_cidr).
resource "azurerm_virtual_network" "aks" {
  name                = "vnet-aks-observability-lab"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "aks_nodes" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.subnet_address_prefix]
}
