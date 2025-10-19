terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
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

resource "azurerm_resource_group" "rg_region1" {
  name     = var.rg_region1_name
  location = var.region1
}

resource "azurerm_resource_group" "rg_region2" {
  name     = var.rg_region2_name
  location = var.region2
}

resource "azurerm_resource_group" "rg_region1_asr" {
  name     = "az104-rg-region1-asr"
  location = var.region2
}

resource "azurerm_network_security_group" "nsg" {
  name                = "az104-10-nsg01"
  location            = azurerm_resource_group.rg_region1.location
  resource_group_name = azurerm_resource_group.rg_region1.name

  security_rule {
    name                       = "default-allow-rdp"
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

resource "azurerm_virtual_network" "vnet" {
  name                = "az104-10-vnet"
  address_space = ["10.0.0.0/24"]
  location            = azurerm_resource_group.rg_region1.location
  resource_group_name = azurerm_resource_group.rg_region1.name
}

resource "azurerm_subnet" "subnet0" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg_region1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.0/26"]
}

resource "azurerm_public_ip" "pip" {
  name                = "az104-10-pip0"
  location            = azurerm_resource_group.rg_region1.location
  resource_group_name = azurerm_resource_group.rg_region1.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "az104-10-nic0"
  location            = azurerm_resource_group.rg_region1.location
  resource_group_name = azurerm_resource_group.rg_region1.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "az104-10-vm0"
  resource_group_name = azurerm_resource_group.rg_region1.name
  location            = azurerm_resource_group.rg_region1.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    name                 = "az104-10-vm0_OsDisk_1_683374612a894f1ca35509b77adde4bd"
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

resource "azurerm_recovery_services_vault" "rsv_region1" {
  name                = "az104-rsv-region1"
  location            = azurerm_resource_group.rg_region1.location
  resource_group_name = azurerm_resource_group.rg_region1.name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant"
  soft_delete_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_backup_policy_vm" "backup_policy" {
  name                = "az104-backup"
  resource_group_name = azurerm_resource_group.rg_region1.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv_region1.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "00:00"
  }

  retention_daily {
    count = 7
  }

  instant_restore_retention_days = 2
}

resource "azurerm_backup_protected_vm" "vm_backup" {
  resource_group_name = azurerm_resource_group.rg_region1.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv_region1.name
  source_vm_id        = azurerm_windows_virtual_machine.vm.id
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy.id

  depends_on = [
    azurerm_windows_virtual_machine.vm
  ]
}

resource "azurerm_storage_account" "diagnostics" {
  name                     = "staccyuliias12"
  resource_group_name      = azurerm_resource_group.rg_region1.name
  location                 = azurerm_resource_group.rg_region1.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  access_tier              = "Hot"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  share_properties {
    retention_policy {
      days = 7
    }
  }
}

resource "azurerm_recovery_services_vault" "rsv_region2" {
  name                = "az104-rsv-region2"
  location            = azurerm_resource_group.rg_region2.location
  resource_group_name = azurerm_resource_group.rg_region2.name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant"
  soft_delete_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_site_recovery_fabric" "source" {
  name                = "az104-fabric-source"
  resource_group_name = azurerm_resource_group.rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv_region2.name
  location            = azurerm_resource_group.rg_region1.location
}

resource "azurerm_site_recovery_fabric" "target" {
  name                = "az104-fabric-target"
  resource_group_name = azurerm_resource_group.rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv_region2.name
  location            = azurerm_resource_group.rg_region2.location
}

resource "azurerm_site_recovery_protection_container" "source" {
  name                 = "az104-protection-container-source"
  resource_group_name  = azurerm_resource_group.rg_region2.name
  recovery_vault_name  = azurerm_recovery_services_vault.rsv_region2.name
  recovery_fabric_name = azurerm_site_recovery_fabric.source.name
}

resource "azurerm_site_recovery_protection_container" "target" {
  name                 = "az104-protection-container-target"
  resource_group_name  = azurerm_resource_group.rg_region2.name
  recovery_vault_name  = azurerm_recovery_services_vault.rsv_region2.name
  recovery_fabric_name = azurerm_site_recovery_fabric.target.name
}

resource "azurerm_site_recovery_replication_policy" "policy" {
  name                                                 = "24-hour-retention-policy"
  resource_group_name                                  = azurerm_resource_group.rg_region2.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.rsv_region2.name
  recovery_point_retention_in_minutes = 1440 # 24 hours
  application_consistent_snapshot_frequency_in_minutes = 240  # 4 hours
}

resource "azurerm_site_recovery_protection_container_mapping" "mapping" {
  name                                      = "az104-container-mapping"
  resource_group_name                       = azurerm_resource_group.rg_region2.name
  recovery_vault_name                       = azurerm_recovery_services_vault.rsv_region2.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.source.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.source.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.target.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
}

resource "azurerm_virtual_network" "vnet_target" {
  name                = "az104-10-vnet-asr"
  address_space = ["10.1.0.0/24"]
  location            = azurerm_resource_group.rg_region1_asr.location
  resource_group_name = azurerm_resource_group.rg_region1_asr.name
}

resource "azurerm_subnet" "subnet_target" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg_region1_asr.name
  virtual_network_name = azurerm_virtual_network.vnet_target.name
  address_prefixes = ["10.1.0.0/26"]
}

resource "azurerm_storage_account" "cache" {
  name                     = "mi8dfzaz104rsvasrcache"
  resource_group_name      = azurerm_resource_group.rg_region2.name
  location                 = azurerm_resource_group.rg_region2.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_automation_account" "asr_automation" {
  name                = "az104-asr-automation-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg_region2.location
  resource_group_name = azurerm_resource_group.rg_region2.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}