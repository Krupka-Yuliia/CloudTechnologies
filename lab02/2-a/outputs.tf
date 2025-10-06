output "management_group_id" {
  description = "Management Group ID"
  value       = azurerm_management_group.az104_mg1.id
}

output "helpdesk_group_id" {
  description = "Help Desk group object ID"
  value       = azuread_group.helpdesk.object_id
}

output "custom_role_id" {
  description = "Custom role definition ID"
  value       = azurerm_role_definition.custom_support_request.role_definition_id
}

output "subscription_id" {
  description = "Current subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}