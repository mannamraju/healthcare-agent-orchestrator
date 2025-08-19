output "id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "vault_uri" {
  description = "The URI of the Key Vault (alias for uri)"
  value       = azurerm_key_vault.main.vault_uri
}
