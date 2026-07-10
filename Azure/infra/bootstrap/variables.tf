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

variable "storage_account_name" {
  description = "Globally-unique storage account name for OpenTofu remote state"
  type        = string
  default     = "sttofuaksvsr02"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    project    = "ai-infra-observability-lab"
    managed-by = "opentofu"
    purpose    = "tofu-state"
  }
}
