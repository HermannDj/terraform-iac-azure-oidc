output "acr_login_server" {
  description = "The login server URL of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "app_service_url" {
  description = "The default URL of the Azure App Service"
  value       = azurerm_app_service.app.default_site_hostname
}