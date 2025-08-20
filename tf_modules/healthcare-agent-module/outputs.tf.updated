output "healthcareAgentServiceEndpoints" {
  description = "Array of Healthcare Agent Service endpoints with management portal links"
  value = [
    for key, bot in azurerm_healthbot.healthcare_agent : {
      id                  = bot.id
      name                = key
      managementPortalLink = bot.bot_management_portal_link
      keyVaultSecretKey    = azurerm_key_vault_secret.healthcare_agent_secret[key].name
    }
  ]
}

output "healthcare_bots" {
  description = "Map of registered healthcare bots"
  value = {
    for k, v in var.healthcare_bots : k => {
      name = v.name
      id   = azurerm_healthbot.healthcare_agent[k].id
    }
  }
}
