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

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "main_vnet" {
  name                = "az104-06-vnet1"
  address_space = ["10.60.0.0/22"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet0" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes = ["10.60.0.0/24"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes = ["10.60.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes = ["10.60.2.0/24"]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "subnet-appgw"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes = ["10.60.3.224/27"]
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "az104-06-nsg1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

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

  security_rule {
    name                       = "default-allow-http"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic0" {
  name                = "az104-06-nic0"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic1" {
  name                = "az104-06-nic1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "az104-06-nic2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nic0_nsg" {
  network_interface_id      = azurerm_network_interface.nic0.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_network_interface_security_group_association" "nic1_nsg" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_network_interface_security_group_association" "nic2_nsg" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_windows_virtual_machine" "vm0" {
  name                = "az104-06-vm0"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  size                = "Standard_B1ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic0.id]

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

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "az104-06-vm1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  size                = "Standard_B1ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic1.id]

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

resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "az104-06-vm2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  size                = "Standard_B1ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic2.id]

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

resource "azurerm_virtual_machine_extension" "vm0_iis" {
  name                 = "customScriptExtension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm0.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -name Web-Server -IncludeManagementTools; if (Test-Path 'C:\\inetpub\\wwwroot\\iisstart.htm') { Remove-Item 'C:\\inetpub\\wwwroot\\iisstart.htm' -Force }; Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)\""
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "vm1_iis" {
  name                 = "customScriptExtension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -name Web-Server -IncludeManagementTools; if (Test-Path 'C:\\inetpub\\wwwroot\\iisstart.htm') { Remove-Item 'C:\\inetpub\\wwwroot\\iisstart.htm' -Force }; Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername); New-Item -Path 'c:\\inetpub\\wwwroot' -Name 'image' -ItemType 'Directory' -Force; New-Item -Path 'c:\\inetpub\\wwwroot\\image\\' -Name 'iisstart.htm' -ItemType 'file' -Force; Add-Content -Path 'C:\\inetpub\\wwwroot\\image\\iisstart.htm' -Value $('Image from: ' + $env:computername)\""
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "vm2_iis" {
  name                 = "customScriptExtension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -name Web-Server -IncludeManagementTools; if (Test-Path 'C:\\inetpub\\wwwroot\\iisstart.htm') { Remove-Item 'C:\\inetpub\\wwwroot\\iisstart.htm' -Force }; Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername); New-Item -Path 'c:\\inetpub\\wwwroot' -Name 'video' -ItemType 'Directory' -Force; New-Item -Path 'c:\\inetpub\\wwwroot\\video\\' -Name 'iisstart.htm' -ItemType 'file' -Force; Add-Content -Path 'C:\\inetpub\\wwwroot\\video\\iisstart.htm' -Value $('Video from: ' + $env:computername)\""
    }
SETTINGS
}

resource "azurerm_public_ip" "lb_pip" {
  name                = "az104-lbpip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "az104-lb"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "az104-fe"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_pool" {
  name            = "az104-be"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm0_assoc" {
  network_interface_id    = azurerm_network_interface.nic0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm1_assoc" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_pool.id
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = "az104-hp"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "az104-lbrule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "az104-fe"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_pool.id]
  probe_id                       = azurerm_lb_probe.lb_probe.id
  idle_timeout_in_minutes        = 4
  enable_tcp_reset               = false
  disable_outbound_snat          = false
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "az104-gwpip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones = ["1"]
}

resource "azurerm_application_gateway" "appgw" {
  name                = "az104-appgw"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "az104-appgwbe"
    ip_addresses = [
      azurerm_network_interface.nic1.private_ip_address,
      azurerm_network_interface.nic2.private_ip_address
    ]
  }

  backend_address_pool {
    name = "az104-imagebe"
    ip_addresses = [azurerm_network_interface.nic1.private_ip_address]
  }

  backend_address_pool {
    name = "az104-videobe"
    ip_addresses = [azurerm_network_interface.nic2.private_ip_address]
  }

  backend_http_settings {
    name                  = "az104-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "az104-listener"
    frontend_ip_configuration_name = "frontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  url_path_map {
    name                               = "az104-pathmap"
    default_backend_address_pool_name  = "az104-appgwbe"
    default_backend_http_settings_name = "az104-http"

    path_rule {
      name                       = "images"
      paths = ["/image/*"]
      backend_address_pool_name  = "az104-imagebe"
      backend_http_settings_name = "az104-http"
    }

    path_rule {
      name                       = "videos"
      paths = ["/video/*"]
      backend_address_pool_name  = "az104-videobe"
      backend_http_settings_name = "az104-http"
    }
  }

  request_routing_rule {
    name               = "az104-gwrule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "az104-listener"
    url_path_map_name  = "az104-pathmap"
    priority           = 10
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }
}
