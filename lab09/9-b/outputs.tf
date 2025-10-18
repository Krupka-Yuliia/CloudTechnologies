output "container_name" {
  description = "Name of the container instance"
  value       = azurerm_container_group.aci.name
}

output "container_fqdn" {
  description = "FQDN to access the container"
  value       = azurerm_container_group.aci.fqdn
}