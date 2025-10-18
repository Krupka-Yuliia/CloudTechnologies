output "application_url" {
  value       = azurerm_container_app.app.ingress[0].fqdn
  description = "Public URL for accessing Azure Container App."
}