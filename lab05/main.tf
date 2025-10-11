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

resource "azurerm_virtual_network" "core_services" {
  name                = "CoreServicesVnet"
  address_space = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "core" {
  name                 = "Core"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core_services.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "core_services_nic" {
  name                = "CoreServicesVM-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.core.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "core_services" {
  name                = "CoreServicesVM"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2ms"
  admin_username      = "localadmin"
  admin_password      = var.vm_password

  network_interface_ids = [
    azurerm_network_interface.core_services_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_virtual_network" "manufacturing" {
  name                = "ManufacturingVnet"
  address_space = ["172.16.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "manufacturing" {
  name                 = "Manufacturing"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes = ["172.16.0.0/24"]
}

resource "azurerm_network_interface" "manufacturing_nic" {
  name                = "ManufacturingVM-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.manufacturing.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "manufacturing" {
  name                = "ManufacturingVM"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2ms"
  admin_username      = "localadmin"
  admin_password      = var.vm_password

  network_interface_ids = [
    azurerm_network_interface.manufacturing_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_network_peering" "core_to_manufacturing" {
  name                         = "CoreServicesVnet-to-ManufacturingVnet"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.core_services.name
  remote_virtual_network_id    = azurerm_virtual_network.manufacturing.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "manufacturing_to_core" {
  name                         = "ManufacturingVnet-to-CoreServicesVnet"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.manufacturing.name
  remote_virtual_network_id    = azurerm_virtual_network.core_services.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_subnet" "perimeter" {
  name                 = "perimeter"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core_services.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_route_table" "core_services" {
  name                          = "rt-CoreServices"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = false
}

resource "azurerm_route" "perimeter_to_core" {
  name                   = "PerimetertoCore"
  resource_group_name    = azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.core_services.name
  address_prefix         = "10.0.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.1.7"
}

resource "azurerm_subnet_route_table_association" "core" {
  subnet_id      = azurerm_subnet.core.id
  route_table_id = azurerm_route_table.core_services.id
}