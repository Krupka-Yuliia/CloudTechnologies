output "vm_id" {
  value       = azurerm_windows_virtual_machine.vm.id
  description = "Virtual machine ID"
}

output "vault_id_region1" {
  value       = azurerm_recovery_services_vault.rsv_rg1.id
  description = "Recovery Services Vault ID (East US)"
}

output "vault_id_region2" {
  value       = azurerm_recovery_services_vault.rsv_rg2.id
  description = "Recovery Services Vault ID (WestUS)"
}
