variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "az104-rg11-2"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westus"
}

variable "vm_name" {
  type        = string
  description = "VM name"
  default     = "az104-vm0"
}

variable "admin_username" {
  type        = string
  description = "Admin username"
  default     = "localadmin"
}

variable "admin_password" {
  type        = string
  description = "Admin password"
  sensitive   = true
}

variable "email" {
  type        = string
  description = "Email for alerts"
}