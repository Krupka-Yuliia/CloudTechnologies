variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "az104-rg7"
}

variable "location" {
  description = "The Azure region to create resources in"
  type        = string
  default     = "East US"
}

variable "storage_name" {
  default = "yuliaastorageacc1181"
}

variable "client_ip_address" {
  description = "client ip address"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}