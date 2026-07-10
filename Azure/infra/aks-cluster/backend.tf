# Remote state backend — points at the storage account created by ../bootstrap.
# Backend config blocks cannot use variables, so these values are literal and
# must match Azure/infra/bootstrap/variables.tf if that config ever changes.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tofu-state"
    storage_account_name = "sttofuaksvsr02"
    container_name       = "tofustate"
    key                  = "aks-cluster.tfstate"
  }
}
