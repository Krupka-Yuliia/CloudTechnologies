variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "az104-rg6"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "localadmin"
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
}