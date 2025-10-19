variable "rg_region1_name" {
  default = "az104-rg-region1"
}

variable "rg_region2_name" {
  default = "az104-rg-region2"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "admin_username" {
  default = "localadmin"
}

variable "admin_password" {
  sensitive = true
  type      = string
}

variable "region1" {
  default = "West Europe"
}

variable "region2" {
  default = "West US"
}
