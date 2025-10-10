terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "core_services_net" {
  name                = "CoreServicesVnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "shared_services_subnet" {
  name                 = "SharedServicesSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core_services_net.name
  address_prefixes = ["10.20.10.0/24"]
}

resource "azurerm_subnet" "database_subnet" {
  name                 = "DatabaseSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core_services_net.name
  address_prefixes = ["10.20.20.0/24"]
}


resource "azurerm_virtual_network" "manufacturing" {
  name                = "ManufacturingVnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "sensor1" {
  name                 = "SensorSubnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes = ["10.30.20.0/24"]
}

resource "azurerm_subnet" "sensor2" {
  name                 = "SensorSubnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes = ["10.30.21.0/24"]
}


resource "azurerm_application_security_group" "asg_web" {
  name                = "asg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "nsg_secure" {
  name                = "myNSGSecure"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_asg" {
  name                        = "AllowASG"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges = ["80", "443"]
  source_application_security_group_ids = [azurerm_application_security_group.asg_web.id]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_secure.name
}

resource "azurerm_network_security_rule" "deny_internet" {
  name                        = "DenyInternetOutbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_secure.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.shared_services_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_secure.id
}


resource "azurerm_dns_zone" "public" {
  name                = var.public_dns
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600
  records = ["10.1.1.4"]
}

resource "azurerm_private_dns_zone" "private" {
  name                = var.private_dns
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "manufacturing_link" {
  name                  = "manufacturing-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private.name
  virtual_network_id    = azurerm_virtual_network.manufacturing.id
  registration_enabled  = false
}

resource "azurerm_private_dns_a_record" "sensorvm" {
  name                = "sensorvm"
  zone_name           = azurerm_private_dns_zone.private.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600
  records = ["10.1.1.4"]
}
