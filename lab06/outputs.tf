output "load_balancer_public_ip" {
  value       = azurerm_public_ip.lb_pip.ip_address
  description = "Public IP of Load Balancer"
}

output "application_gateway_public_ip" {
  value       = azurerm_public_ip.appgw_pip.ip_address
  description = "Public IP of Application Gateway"
}

output "vm0_private_ip" {
  value = azurerm_network_interface.nic0.private_ip_address
}

output "vm1_private_ip" {
  value = azurerm_network_interface.nic1.private_ip_address
}

output "vm2_private_ip" {
  value = azurerm_network_interface.nic2.private_ip_address
}