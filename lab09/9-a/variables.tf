variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "az104-rg9"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "web_app_name" {
  description = "Web app name"
  type        = string
  default     = "yuliaas2webapp121233"
}
