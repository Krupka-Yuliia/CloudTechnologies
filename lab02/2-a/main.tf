terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}

data "azurerm_subscription" "current" {}

data "azurerm_management_group" "root" {
  name = data.azurerm_subscription.current.tenant_id
}

resource "azurerm_management_group" "az104_mg1" {
  name         = "az104-mg1"
  display_name = "az104-mg1"

  parent_management_group_id = data.azurerm_management_group.root.id
}

resource "azurerm_management_group_subscription_association" "az104_mg1" {
  management_group_id = azurerm_management_group.az104_mg1.id
  subscription_id     = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
}

resource "azuread_group" "helpdesk" {
  display_name     = "helpdesk"
  security_enabled = true
  description      = "Help desk support group"
}

resource "azurerm_role_assignment" "virtual_machine_contributor" {
  scope                = azurerm_management_group.az104_mg1.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azuread_group.helpdesk.object_id

  depends_on = [
    azurerm_management_group.az104_mg1,
    azuread_group.helpdesk
  ]
}

resource "azurerm_role_definition" "custom_support_request" {
  name        = "Custom Support Request"
  scope       = azurerm_management_group.az104_mg1.id
  description = "Custom contributor role for support requests."

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Support/*"
    ]

    not_actions = [
      "Microsoft.Support/register/action"
    ]
  }

  assignable_scopes = [
    azurerm_management_group.az104_mg1.id
  ]

  depends_on = [
    azurerm_management_group.az104_mg1
  ]
}