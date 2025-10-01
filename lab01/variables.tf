variable "domain_name" {
  description = "The domain name of your Azure AD tenant"
  type        = string
}

variable "guest_email" {
  description = "Email for inviting an external user (leave empty to skip)"
  type        = string
  default     = ""
}

variable "guest_name" {
  description = "Name of the external user"
  type        = string
  default     = "Guest User"
}
