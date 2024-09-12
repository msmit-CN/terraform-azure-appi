output "config" {
  description = "configuration for applications insights"
  value       = azurerm_application_insights.appi
}

output "api_keys" {
  description = "api keys for applications insights"
  value       = azurerm_application_insights_api_key.api_key
}