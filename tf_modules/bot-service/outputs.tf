output "bot_ids" {
  description = "The IDs of the created Bot Services"
  value = {
    for key, bot in azurerm_bot_service_azure_bot.bots : key => bot.id
  }
}

output "bot_names" {
  description = "The names of the created Bot Services"
  value = {
    for key, bot in azurerm_bot_service_azure_bot.bots : key => bot.name
  }
}

output "bot_endpoints" {
  description = "The endpoints of the created Bot Services"
  value = {
    for key, bot in azurerm_bot_service_azure_bot.bots : key => bot.endpoint
  }
}
