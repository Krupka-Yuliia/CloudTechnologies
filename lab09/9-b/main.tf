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

resource "azurerm_resource_group" "rg_lab9b" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_group" "aci" {
  name                = "az104-c1"
  location            = azurerm_resource_group.rg_lab9b.location
  resource_group_name = azurerm_resource_group.rg_lab9b.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = var.dns_name_label
  restart_policy      = "Always"

  container {
    name   = "az104-container"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = 1
    memory = 1.5

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}