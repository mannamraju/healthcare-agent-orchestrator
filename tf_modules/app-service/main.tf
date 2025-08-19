# App Service Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Key Vault Secret for Graph RAG
resource "azurerm_key_vault_secret" "graph_rag_key" {
  count = var.graph_rag_subscription_key != "" ? 1 : 0
  
  name         = "graph-rag-subscription-key"
  value        = var.graph_rag_subscription_key
  key_vault_id = var.key_vault_id
}

# Create bot IDs object for app settings
locals {
  bot_ids = {
    for name, identity in var.managed_identities : name => identity.client_id
  }
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.app_service_plan_id
  tags                = merge(var.tags, { "azd-service-name" = "healthcare-agent-orchestrator-app" })
  
  virtual_network_subnet_id = var.subnet_id

  identity {
    type = "UserAssigned"
    identity_ids = [
      for identity in var.managed_identities : identity.id
    ]
  }

  key_vault_reference_identity_id = values(var.managed_identities)[0].id

  site_config {
    always_on         = true
    http2_enabled     = true
    app_command_line  = "gunicorn app:app"
    
    application_stack {
      python_version = "3.12"
    }
    
    ip_restriction {
      action = "Allow"
      headers {
        x_azure_fdid      = []
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }
      name        = "VNet"
      priority    = 100
      service_tag = "VirtualNetwork"
    }

    dynamic "ip_restriction" {
      for_each = var.additional_allowed_ips
      content {
        ip_address = ip_restriction.value
        name       = "AllowedIP-${ip_restriction.key}"
        priority   = 200 + ip_restriction.key
        action     = "Allow"
        headers {
          x_azure_fdid      = []
          x_fd_health_probe = []
          x_forwarded_for   = []
          x_forwarded_host  = []
        }
      }
    }
  }

  https_only = true

  app_settings = merge({
    "MicrosoftAppType"                            = "UserAssignedMSI"
    "AZURE_CLIENT_ID"                            = values(var.managed_identities)[0].client_id
    "MicrosoftAppTenantId"                       = data.azurerm_client_config.current.tenant_id
    "AZURE_AI_PROJECT_CONNECTION_STRING"         = var.ai_project_connection_string
    "AZURE_OPENAI_API_ENDPOINT"                  = var.openai_endpoint
    "AZURE_OPENAI_ENDPOINT"                      = var.openai_endpoint
    "AZURE_OPENAI_REASONING_MODEL_ENDPOINT"      = var.openai_endpoint_reasoning_model
    "AZURE_OPENAI_DEPLOYMENT_NAME"               = var.deployment_name
    "AZURE_OPENAI_DEPLOYMENT_NAME_REASONING_MODEL" = var.deployment_name_reasoning_model
    "APP_BLOB_STORAGE_ENDPOINT"                  = var.app_blob_storage_endpoint
    "SCM_DO_BUILD_DURING_DEPLOYMENT"             = "true"
    "ENABLE_ORYX_BUILD"                          = "true"
    "DEBUG"                                      = "true"
    "BOT_IDS"                                    = jsonencode(local.bot_ids)
    "HLS_MODEL_ENDPOINTS"                        = jsonencode(var.model_endpoints)
    "BACKEND_APP_HOSTNAME"                       = "${var.name}.azurewebsites.net"
    "SCENARIO"                                   = var.scenario
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.application_insights_connection_string
  }, 
  # Graph RAG Key
  var.graph_rag_subscription_key != "" ? {
    "GRAPH_RAG_SUBSCRIPTION_KEY" = "@Microsoft.KeyVault(VaultName=${split(".", split("//", var.key_vault_uri)[1])[0]};SecretName=${azurerm_key_vault_secret.graph_rag_key[0].name})"
  } : {},
  # Clinical Notes Settings
  var.clinical_notes_source == "fhir" && var.fhir_service_endpoint != "" ? {
    "CLINICAL_NOTES_SOURCE" = "fhir"
    "FHIR_SERVICE_ENDPOINT" = var.fhir_service_endpoint
  } : var.clinical_notes_source == "fabric" && var.fabric_user_data_function_endpoint != "" ? {
    "CLINICAL_NOTES_SOURCE" = "fabric" 
    "FABRIC_USER_DATA_FUNCTION_ENDPOINT" = var.fabric_user_data_function_endpoint
  } : {
    "CLINICAL_NOTES_SOURCE" = "none"
  })

  # Authentication configuration (conditional)
  dynamic "auth_settings_v2" {
    for_each = var.auth_client_id != "" ? [1] : []
    content {
      auth_enabled                            = true
      require_authentication                  = true
      unauthenticated_action                  = "RedirectToLoginPage"
      default_provider                        = "azureactivedirectory"
      
      excluded_paths = [
        for name in keys(var.managed_identities) : "/api/${name}/messages"
      ]

      active_directory_v2 {
        client_id                 = var.auth_client_id
        tenant_auth_endpoint      = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
        allowed_audiences         = ["https://${var.name}.azurewebsites.net/.auth/login/aad/callback"]
      }
      
      login {
        logout_endpoint = "/.auth/logout"
      }
    }
  }
}
