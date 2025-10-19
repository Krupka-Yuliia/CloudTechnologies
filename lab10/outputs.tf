output "vm_name" {
  value = azurerm_windows_virtual_machine.vm.name
}

output "recovery_vault_region1" {
  value = azurerm_recovery_services_vault.rsv_region1.name
}

output "recovery_vault_region2" {
  value = azurerm_recovery_services_vault.rsv_region2.name
}

output "storage_account_diagnostics" {
  value = azurerm_storage_account.diagnostics.name
}