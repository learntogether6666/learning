variable "subscription_id" {
  description = "Azure subscription ID to deploy into (Visual Studio Enterprise subscription, Vidya@pranjalshrivastavahotmail.onmicrosoft.com account — kept separate from the DCGM VM lab's subscription 0a5a25eb)"
  type        = string
  default     = "a04c60cd-2bf3-4e74-9625-a54212845d2b"
}

variable "location" {
  description = "Azure region (matches rg-dcgm-lab / existing quota)"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group for the AKS cluster and its VNet"
  type        = string
  default     = "rg-aks-observability-lab"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-observability-lab"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS API server FQDN"
  type        = string
  default     = "aks-obs-lab"
}

variable "system_vm_size" {
  description = "VM size for the system node pool (never Spot — must stay available for CoreDNS etc.)"
  type        = string
  default     = "Standard_B2s"
}

variable "general_vm_size" {
  description = "VM size for the general workload node pool (Regular/on-demand priority — both Standard_B2s and Standard_D2s_v3 hit SkuNotAvailable for Spot capacity in eastus at cluster-creation time)."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "general_min_count" {
  description = "Minimum nodes in the general (Spot) autoscaled pool"
  type        = number
  default     = 1
}

variable "general_max_count" {
  description = "Maximum nodes in the general (Spot) autoscaled pool"
  type        = number
  default     = 3
}

variable "vnet_address_space" {
  description = "Address space for the cluster VNet (node IPs; pods use the Azure CNI Overlay range, not this)"
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Subnet for AKS nodes"
  type        = string
  default     = "10.20.1.0/24"
}

variable "pod_cidr" {
  description = "Overlay pod CIDR (Azure CNI Overlay mode) — separate from the VNet address space"
  type        = string
  default     = "10.244.0.0/16"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    project    = "ai-infra-observability-lab"
    managed-by = "opentofu"
  }
}
