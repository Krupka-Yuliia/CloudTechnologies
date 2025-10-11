variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = "az104-rg5"
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
  default     = "East US"
}

variable "vm_password" {
  description = "Password for the virtual machines."
  type        = string
  sensitive   = true
  default     = "cgdPass22323bb!W"
}