terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg_lab7" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  address_space = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_lab7.location
  resource_group_name = azurerm_resource_group.rg_lab7.name
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg_lab7.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.rg_lab7.name
  location                 = azurerm_resource_group.rg_lab7.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = false

    delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action = "Deny"
    bypass = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.default_subnet.id]
    ip_rules = [var.client_ip_address]
  }
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container_immutability_policy" "data_policy" {
  storage_container_resource_manager_id = azurerm_storage_container.data.resource_manager_id
  immutability_period_in_days           = 180
}

resource "azurerm_storage_management_policy" "policy" {
  storage_account_id = azurerm_storage_account.storage.id

  rule {
    name    = "MoveToCool"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
      prefix_match = ["data/"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
}

resource "azurerm_storage_share" "share1" {
  name                 = "share1"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50
  access_tier          = "TransactionOptimized"
}