output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.storage.name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary Blob endpoint URL."
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "storage_account_primary_file_endpoint" {
  description = "The primary File endpoint URL."
  value       = azurerm_storage_account.storage.primary_file_endpoint
}

output "container_name" {
  description = "The name of the Blob Container."
  value       = azurerm_storage_container.data.name
}

output "file_share_name" {
  description = "The name of the File Share."
  value       = azurerm_storage_share.share1.name
}

output "blob_container_url" {
  description = "The URL for the Blob Container."
  value       = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net/${azurerm_storage_container.data.name}"
}

output "file_share_url" {
  description = "The URL for the File Share."
  value       = "https://${azurerm_storage_account.storage.name}.file.core.windows.net/${azurerm_storage_share.share1.name}"
}