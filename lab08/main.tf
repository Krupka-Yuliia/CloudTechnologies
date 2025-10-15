terraform {
  required_version = ">= 1.0.0"

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

resource "azurerm_resource_group" "rg08" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vm_vnet" {
  name                = "vm-vnet"
  address_space = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg08.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes = ["10.0.1.0/24"]

  depends_on = [
    azurerm_virtual_network.vm_vnet
  ]
}

resource "azurerm_public_ip" "vm_pip" {
  count               = 2
  name                = "az104-vm${count.index + 1}-pip"
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones = [tostring(count.index + 1)]
}

resource "azurerm_network_interface" "vm_nic" {
  count               = 2
  name                = "az104-vm${count.index + 1}-nic"
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = 2
  name                = "az104-vm${count.index + 1}"
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name
  size                = var.size
  zone = tostring(count.index + 1)
  admin_username      = var.vm_username
  admin_password      = var.vm_password
  network_interface_ids = [
    azurerm_network_interface.vm_nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode            = "AutomaticByPlatform"

  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_managed_disk" "vm1_disk1" {
  name                 = "vm1-disk1"
  location             = azurerm_resource_group.rg08.location
  resource_group_name  = azurerm_resource_group.rg08.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
  zone                 = "1"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm1_disk1_attach" {
  managed_disk_id    = azurerm_managed_disk.vm1_disk1.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm[0].id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_virtual_network" "vmss_vnet" {
  name                = "vmss-vnet"
  address_space = ["10.82.0.0/20"]
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name
}

resource "azurerm_subnet" "vmss_subnet0" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg08.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes = ["10.82.0.0/24"]
}

resource "azurerm_network_security_group" "vmss1_nsg" {
  name                = "vmss1-nsg"
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name

  security_rule {
    name                       = "allow-http"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "vmss_lb_pip" {
  name                = "vmss-lb-pip"
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "vmss_lb" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss_lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "vmss_backend_pool" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "BackEndAddressPool"

  depends_on = [
    azurerm_lb.vmss_lb
  ]
}

resource "azurerm_lb_probe" "vmss_probe" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80

  depends_on = [
    azurerm_lb.vmss_lb
  ]
}

resource "azurerm_lb_rule" "vmss_lb_rule" {
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_backend_pool.id]
  probe_id                       = azurerm_lb_probe.vmss_probe.id

  depends_on = [
    azurerm_lb_backend_address_pool.vmss_backend_pool,
    azurerm_lb_probe.vmss_probe
  ]
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                = "vmss1"
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name
  sku                 = var.size
  instances           = 2
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zones = ["1", "2", "3"]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "vmss-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.vmss1_nsg.id

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.vmss_subnet0.id
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.vmss_backend_pool.id
      ]
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "vmss-autoscale"
  location            = azurerm_resource_group.rg08.location
  resource_group_name = azurerm_resource_group.rg08.name
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "PercentChangeCount"
        value     = "50"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "PercentChangeCount"
        value     = "50"
        cooldown  = "PT5M"
      }
    }
  }
}