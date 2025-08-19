output "bot_identities" {
  description = "Map of bot names to their managed identities"
  value = { for name, identity in azurerm_user_assigned_identity.bot_identities : name => {
    id           = identity.id
    principal_id = identity.principal_id
    client_id    = identity.client_id
  } }
}

output "bot_services" {
  description = "Map of bot names to their service resources"
  value = { for name, bot in azurerm_bot_service_azure_bot.bots : name => {
    id       = bot.id
    name     = bot.name
    endpoint = bot.endpoint
  } }
}
