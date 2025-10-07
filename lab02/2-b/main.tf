terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = "az104-rg2"
  location = var.location

  tags = {
    CostCenter = "000"
  }
}

data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag and its value on resources"
}

# This is tested in Task 2 of the lab but then deleted in Task 3

# resource "azurerm_resource_group_policy_assignment" "require_tag" {
#   name                 = "require-cc-tag"
#   resource_group_id    = azurerm_resource_group.rg.id
#   policy_definition_id = data.azurerm_policy_definition.require_tag.id
#   display_name         = "Require Cost Center tag and its value on resources"
#   description          = "Require Cost Center tag and its value on all resources in the resource group"
#
#   parameters = jsonencode({
#     tagName = { value = "CostCenter" }
#     tagValue = { value = "000" }
#   })
# }

data "azurerm_policy_definition" "inherit_tag" {
  display_name = "Inherit a tag from the resource group if missing"
}

resource "azurerm_resource_group_policy_assignment" "inherit_tag" {
  name                 = "inherit-cc-tag"
  resource_group_id    = azurerm_resource_group.rg.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag.id
  display_name         = "Inherit the Cost Center tag and its value 000 from the resource group if missing"
  description          = "Inherit the Cost Center tag and its value 000 from the resource group if missing"

  parameters = jsonencode({
    tagName = { value = "CostCenter" }
  })

  identity {
    type = "SystemAssigned"
  }

  location = var.location

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_resource_policy_remediation" "inherit_tag" {
  name                    = "remediate-cc-tag"
  resource_id             = azurerm_resource_group.rg.id
  policy_assignment_id    = azurerm_resource_group_policy_assignment.inherit_tag.id
  resource_discovery_mode = "ReEvaluateCompliance"

  depends_on = [azurerm_resource_group_policy_assignment.inherit_tag]
}

resource "random_string" "stg_name" {
  length  = 10
  special = false
  upper   = false
  numeric = true
}

resource "azurerm_storage_account" "stg" {
  name                     = "juliasst${random_string.stg_name.result}2612"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [
    azurerm_resource_group_policy_assignment.inherit_tag,
    azurerm_resource_policy_remediation.inherit_tag
  ]
}

resource "azurerm_management_lock" "lock" {
  name       = "rg-lock"
  scope      = azurerm_resource_group.rg.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of the resource group"
}