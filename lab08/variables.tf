variable "vm_username" {
  type        = string
  description = "username for vm"
  default     = "localadmin"
}

variable "vm_password" {
  type        = string
  description = "vm password"
  sensitive   = true
}
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "az104-rg8"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "polandcentral"
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
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "size" {
  description = "Size of vm and sku"
  default = "Standard_B1s"
}