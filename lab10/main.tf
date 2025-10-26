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
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "rg_reg1" {
  name     = var.resource_group_region1
  location = var.region1
}

resource "azurerm_resource_group" "rg_reg2" {
  name     = var.resource_group_region2
  location = var.region2
}

resource "azurerm_virtual_network" "vnet" {
  name                = "az104-vnet"
  address_space = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_reg1.location
  resource_group_name = azurerm_resource_group.rg_reg1.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg_reg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "az104-pip"
  location            = azurerm_resource_group.rg_reg1.location
  resource_group_name = azurerm_resource_group.rg_reg1.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "az104-nsg01"
  location            = azurerm_resource_group.rg_reg1.location
  resource_group_name = azurerm_resource_group.rg_reg1.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "az104-nic"
  location            = azurerm_resource_group.rg_reg1.location
  resource_group_name = azurerm_resource_group.rg_reg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_windows_virtual_machine" "vm" {
  name                = "az104-10-vm0"
  resource_group_name = azurerm_resource_group.rg_reg1.name
  location            = azurerm_resource_group.rg_reg1.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id
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

resource "azurerm_recovery_services_vault" "rsv_rg1" {
  name                = var.rsv_region1
  location            = azurerm_resource_group.rg_reg1.location
  resource_group_name = azurerm_resource_group.rg_reg1.name
  sku                 = "Standard"
  soft_delete_enabled = true
}

resource "azurerm_backup_policy_vm" "backup_policy" {
  name                = "az104-backup"
  resource_group_name = azurerm_resource_group.rg_reg1.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv_rg1.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "00:00"
  }

  retention_daily {
    count = 7
  }
}

resource "azurerm_storage_account" "diagnostic" {
  name                     = "juliasorageacc1221"
  resource_group_name      = azurerm_resource_group.rg_reg1.name
  location                 = azurerm_resource_group.rg_reg1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_recovery_services_vault" "rsv_rg2" {
  name                = var.rsv_region2
  location            = azurerm_resource_group.rg_reg2.location
  resource_group_name = azurerm_resource_group.rg_reg2.name
  sku                 = "Standard"
  soft_delete_enabled = true
}