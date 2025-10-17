output "production_webapp_url" {
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
  description = "Production Web App URL"
}

output "staging_slot_url" {
  value       = "https://${azurerm_linux_web_app_slot.staging.default_hostname}"
  description = "Staging Slot URL"
}

output "webapp_name" {
  value       = azurerm_linux_web_app.webapp.name
  description = "Web App Name"
}
