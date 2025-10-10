variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "az104-rg3"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "disk_size" {
  description = "Disks size in GB"
  type        = number
  default     = 32
}