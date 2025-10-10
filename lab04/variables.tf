variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "az104-rg4"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "public_dns" {
  description = "Public dns name"
  type        = string
  default     = "contoso266.com"
}

variable "private_dns" {
  description = "Private dns name"
  type        = string
  default     = "private.contoso266.com"
}