output "az104_vm1_public_ip" {
  description = "Public IP address for az104-vm1"
  value       = azurerm_public_ip.vm_pip[0].ip_address
}

output "az104_vm2_public_ip" {
  description = "Public IP address for az104-vm2"
  value       = azurerm_public_ip.vm_pip[1].ip_address
}

output "vmss_load_balancer_ip" {
  description = "Public IP address for VMSS Load Balancer"
  value       = azurerm_public_ip.vmss_lb_pip.ip_address
}

output "az104_vm1_private_ip" {
  description = "Private IP address for az104-vm1"
  value       = azurerm_network_interface.vm_nic[0].private_ip_address
}

output "az104_vm2_private_ip" {
  description = "Private IP address for az104-vm2"
  value       = azurerm_network_interface.vm_nic[1].private_ip_address
}

output "vmss_name" {
  description = "Name of the VM Scale Set"
  value       = azurerm_windows_virtual_machine_scale_set.vmss.name
}

output "vm_virtual_network_name" {
  description = "Name of the VM virtual network"
  value       = azurerm_virtual_network.vm_vnet.name
}

output "vmss_virtual_network_name" {
  description = "Name of the VMSS virtual network"
  value       = azurerm_virtual_network.vmss_vnet.name
}