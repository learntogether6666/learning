terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_cli         = true
}

resource "azurerm_resource_group" "tofu_state" {
  name     = "rg-tofu-state"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tofu_state" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.tofu_state.name
  location                 = azurerm_resource_group.tofu_state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tofu_state" {
  name                  = "tofustate"
  storage_account_id   = azurerm_storage_account.tofu_state.id
  container_access_type = "private"
}
