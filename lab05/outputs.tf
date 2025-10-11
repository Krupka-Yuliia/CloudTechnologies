output "core_services_vm_private_ip" {
  value       = azurerm_network_interface.core_services_nic.private_ip_address
  description = "CoreServicesVM's private IP address"
}

output "manufacturing_vm_private_ip" {
  value       = azurerm_network_interface.manufacturing_nic.private_ip_address
  description = "Private IP address of ManufacturingVM"
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Name of the resource group"
}