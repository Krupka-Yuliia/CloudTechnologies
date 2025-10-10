output "resource_group_name" {
  value       = azurerm_resource_group.lab03.name
  description = "Resource group name"
}

output "disk1_id" {
  value       = azurerm_managed_disk.disk1.id
  description = "Disk 1 ID"
}

output "disk2_id" {
  value       = azurerm_managed_disk.disk2.id
  description = "Disk 2 ID"
}

output "disk3_id" {
  value       = azurerm_managed_disk.disk3.id
  description = "Disk 3 ID"
}

output "disk4_id" {
  value       = azurerm_managed_disk.disk4.id
  description = "Disk 4 ID"
}

output "disk5_id" {
  value       = azurerm_managed_disk.disk5.id
  description = "Disk 5 ID (SSD)"
}

output "all_disks" {
  value = {
    disk1 = azurerm_managed_disk.disk1.name
    disk2 = azurerm_managed_disk.disk2.name
    disk3 = azurerm_managed_disk.disk3.name
    disk4 = azurerm_managed_disk.disk4.name
    disk5 = azurerm_managed_disk.disk5.name
  }
}