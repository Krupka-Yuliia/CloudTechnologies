output "core_services_vnet_id" {
  description = "ID of CoreServicesVnet"
  value       = azurerm_virtual_network.core_services_net.id
}

output "manufacturing_vnet_id" {
  description = "ID of ManufacturingVnet"
  value       = azurerm_virtual_network.manufacturing.id
}

output "public_dns_zone_nameservers" {
  description = "Name servers for public DNS zone"
  value       = azurerm_dns_zone.public.name_servers
}

output "nsg_id" {
  description = "ID of Network Security Group"
  value       = azurerm_network_security_group.nsg_secure.id
}

output "asg_id" {
  description = "ID of Application Security Group"
  value       = azurerm_application_security_group.asg_web.id
}