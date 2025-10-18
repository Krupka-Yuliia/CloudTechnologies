output "production_url" {
  description = "Production Web App URL"
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
}

output "staging_url" {
  description = "Staging Slot URL"
  value       = "https://${azurerm_linux_web_app_slot.staging.default_hostname}"
}
output "web_app_name" {
  description = "Web App Name"
  value       = azurerm_linux_web_app.webapp.name
}

output "app_service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.asp.id
}