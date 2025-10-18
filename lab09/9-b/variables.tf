variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}
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

variable "dns_name_label" {
  description = "DNS name label for the container"
  type        = string
  default     = "juliia2ssdns122"
}