terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "lab11_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "az104-law-huweg76768o87"
  location            = azurerm_resource_group.lab11_rg.location
  resource_group_name = azurerm_resource_group.lab11_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "vnet" {
  name                = "az104-vnet"
  address_space = ["10.0.0.0/24"]
  location            = azurerm_resource_group.lab11_rg.location
  resource_group_name = azurerm_resource_group.lab11_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.lab11_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.0/26"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "az104-nsg01"
  location            = azurerm_resource_group.lab11_rg.location
  resource_group_name = azurerm_resource_group.lab11_rg.name

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

resource "azurerm_public_ip" "pip" {
  name                = "az104-pip"
  location            = azurerm_resource_group.lab11_rg.location
  resource_group_name = azurerm_resource_group.lab11_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "az104-nic"
  location            = azurerm_resource_group.lab11_rg.location
  resource_group_name = azurerm_resource_group.lab11_rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_storage_account" "sa" {
  name                     = "az10411gjhf6t6676566"
  resource_group_name      = azurerm_resource_group.lab11_rg.name
  location                 = azurerm_resource_group.lab11_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.lab11_rg.name
  location            = azurerm_resource_group.lab11_rg.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

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

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sa.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "ama" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "dependency" {
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true

  depends_on = [azurerm_virtual_machine_extension.ama]
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "MSVMI-${azurerm_log_analytics_workspace.law.name}"
  location            = azurerm_resource_group.lab11_rg.location
  resource_group_name = azurerm_resource_group.lab11_rg.name

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "VMInsightsPerf-Logs-Dest"
    }
  }

  data_flow {
    streams = ["Microsoft-InsightsMetrics"]
    destinations = ["VMInsightsPerf-Logs-Dest"]
  }

  data_flow {
    streams = ["Microsoft-ServiceMap"]
    destinations = ["VMInsightsPerf-Logs-Dest"]
  }

  data_sources {
    performance_counter {
      streams = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
      name = "VMInsightsPerfCounters"
    }

    extension {
      streams = ["Microsoft-ServiceMap"]
      extension_name = "DependencyAgent"
      name           = "DependencyAgentDataSource"
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "dcra" {
  name                    = "dcra-${var.vm_name}"
  target_resource_id      = azurerm_windows_virtual_machine.vm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id

  depends_on = [
    azurerm_virtual_machine_extension.ama,
    azurerm_virtual_machine_extension.dependency
  ]
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "Alert the operations team"
  resource_group_name = azurerm_resource_group.lab11_rg.name
  short_name          = "AlertOpsTeam"
  location            = "global"

  email_receiver {
    name          = "VM was deleted"
    email_address = var.email
  }
}

resource "azurerm_monitor_activity_log_alert" "vm_deleted" {
  name                = "VM was deleted"
  resource_group_name = azurerm_resource_group.lab11_rg.name
  scopes              = [data.azurerm_subscription.current.id]
  description         = "A VM in your resource group was deleted"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.Compute/virtualMachines"
    operation_name = "Microsoft.Compute/virtualMachines/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}

resource "azurerm_monitor_alert_processing_rule_suppression" "maintenance" {
  name                = "PlannedMaintenance"
  resource_group_name = azurerm_resource_group.lab11_rg.name
  scopes = [azurerm_resource_group.lab11_rg.id]
  description         = "Suppress notifications during planned maintenance"
  enabled             = true

  schedule {
    recurrence {
      daily {
        start_time = "22:00:00"
        end_time   = "07:00:00"
      }
    }
    time_zone = "UTC-02"
  }
}