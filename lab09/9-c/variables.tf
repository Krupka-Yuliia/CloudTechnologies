variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "az104-rg9"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}