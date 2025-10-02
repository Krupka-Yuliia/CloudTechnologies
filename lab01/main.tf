terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azuread" {
}

data "azuread_client_config" "current" {}

resource "random_password" "user_password" {
  length           = 16
  special          = true
  override_special = "!@#$%"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}


resource "azuread_user" "az104_user1" {
  user_principal_name = "az104-user1@${var.domain_name}"
  display_name        = "az104-user1"
  mail_nickname       = "az104-user1"
  password            = random_password.user_password.result

  job_title      = "IT Lab Administrator"
  department     = "IT"
  usage_location = "US"

  account_enabled       = true
  force_password_change = false
}

resource "azuread_invitation" "guest_user" {
  count = var.guest_email != "" ? 1 : 0

  user_email_address = var.guest_email
  user_display_name  = var.guest_name
  redirect_url       = "https://portal.azure.com"

  message {
    body = "Welcome to Azure and our group project"
  }
}

resource "azuread_group" "it_lab_administrators" {
  display_name     = "IT Lab Administrators"
  description      = "Administrators that manage the IT lab"
  security_enabled = true

  owners = [
    data.azuread_client_config.current.object_id
  ]

  members = [
    azuread_user.az104_user1.object_id
  ]
}

resource "azuread_group_member" "guest_member" {
  count = var.guest_email != "" ? 1 : 0

  group_object_id  = azuread_group.it_lab_administrators.object_id
  member_object_id = azuread_invitation.guest_user[0].user_id

  depends_on = [azuread_invitation.guest_user]
}