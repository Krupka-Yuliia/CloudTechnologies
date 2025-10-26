variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "region1" {
  default     = "Central US"
  description = "Primary region"
}

variable "region2" {
  default     = "West US"
  description = "Secondary region for disaster recovery"
}

variable "resource_group_region1" {
  default     = "az104-rg-region1"
  description = "Resource group in East US"
}

variable "resource_group_region2" {
  default     = "az104-rg-region2"
  description = "Resource group in West US"
}


variable "admin_username" {
  default     = "localadmin"
  description = "Admin username for the VM"
}

variable "admin_password" {
  description = "Admin password for the VM"
  sensitive   = true
}

variable "rsv_region1" {
  default     = "az104-rsv-region1"
  description = "Recovery Services Vault in East US"
}

variable "rsv_region2" {
  default     = "az104-rsv-region2"
  description = "Recovery Services Vault in West US"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}
