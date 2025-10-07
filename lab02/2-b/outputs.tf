output "resource_group_name" {
  description = "Resource Group name"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "Resource Group ID"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_tags" {
  description = "Resource Group tags"
  value       = azurerm_resource_group.rg.tags
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = azurerm_storage_account.stg.name
}

output "storage_account_tags" {
  description = "Storage Account tags (should inherit CostCenter)"
  value       = azurerm_storage_account.stg.tags
}

output "resource_lock_id" {
  description = "Resource Lock ID"
  value       = azurerm_management_lock.lock.id
}
