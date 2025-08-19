# Healthcare Agent Orchestrator - Cleanup Module
# This module provides safe and comprehensive cleanup of the healthcare agent orchestrator deployment

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = true
      purge_soft_deleted_keys_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {
  # Configuration options
}

# Variables for cleanup configuration
variable "resource_group_name" {
  description = "Name of the resource group to cleanup"
  type        = string
}

variable "confirm_destroy" {
  description = "Set to 'yes' to confirm you want to destroy all resources"
  type        = string
  default     = "no"
  validation {
    condition     = contains(["yes", "no"], var.confirm_destroy)
    error_message = "You must set confirm_destroy to 'yes' to proceed with cleanup."
  }
}

variable "preserve_data" {
  description = "Set to true to preserve storage accounts and their data during cleanup"
  type        = bool
  default     = false
}

variable "force_cleanup" {
  description = "Set to true to force cleanup even if some resources fail to delete"
  type        = bool
  default     = false
}

# Data sources to identify existing resources
data "azurerm_resource_group" "main" {
  count = var.confirm_destroy == "yes" ? 1 : 0
  name  = var.resource_group_name
}

data "azurerm_resources" "all" {
  count               = var.confirm_destroy == "yes" ? 1 : 0
  resource_group_name = var.resource_group_name
}

# Local values for cleanup logic
locals {
  should_cleanup = var.confirm_destroy == "yes"
  
  # Resource types that should be cleaned up in specific order
  cleanup_order = [
    "Microsoft.BotService/botServices",
    "Microsoft.Web/sites",
    "Microsoft.Web/serverfarms", 
    "Microsoft.MachineLearningServices/workspaces",
    "Microsoft.CognitiveServices/accounts",
    "Microsoft.KeyVault/vaults",
    "Microsoft.ManagedIdentity/userAssignedIdentities",
    "Microsoft.Storage/storageAccounts"
  ]
  
  # Resources to preserve if preserve_data is true
  preserved_types = var.preserve_data ? [
    "Microsoft.Storage/storageAccounts"
  ] : []
}

# Pre-cleanup validation
resource "null_resource" "pre_cleanup_validation" {
  count = local.should_cleanup ? 1 : 0
  
  triggers = {
    resource_group = var.resource_group_name
    timestamp      = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Pre-cleanup validation for resource group: ${var.resource_group_name}"
      
      # Check if resource group exists
      if az group show --name "${var.resource_group_name}" >/dev/null 2>&1; then
        echo "✅ Resource group '${var.resource_group_name}' found"
      else
        echo "❌ Resource group '${var.resource_group_name}' not found"
        exit 1
      fi
      
      # List resources to be deleted
      echo "📋 Resources found in resource group:"
      az resource list --resource-group "${var.resource_group_name}" --query "[].{Name:name, Type:type, Location:location}" --output table
      
      # Check for protected resources
      protected_count=$(az resource list --resource-group "${var.resource_group_name}" --query "[?tags.Protected=='true'] | length(@)")
      if [ "$protected_count" -gt 0 ]; then
        echo "⚠️  Warning: Found $protected_count protected resources. Review before proceeding."
        az resource list --resource-group "${var.resource_group_name}" --query "[?tags.Protected=='true'].{Name:name, Type:type}" --output table
      fi
      
      echo "✅ Pre-cleanup validation complete"
    EOT
  }
}

# Cleanup Bot Services first (they depend on other resources)
resource "null_resource" "cleanup_bot_services" {
  count      = local.should_cleanup ? 1 : 0
  depends_on = [null_resource.pre_cleanup_validation]
  
  triggers = {
    resource_group = var.resource_group_name
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🤖 Cleaning up Bot Services..."
      
      # Get all bot services in the resource group
      bot_services=$(az botservice list --resource-group "${var.resource_group_name}" --query "[].name" -o tsv)
      
      if [ -n "$bot_services" ]; then
        echo "Found bot services to delete:"
        echo "$bot_services"
        
        # Delete each bot service
        echo "$bot_services" | while read -r bot; do
          if [ -n "$bot" ]; then
            echo "🗑️  Deleting bot service: $bot"
            az botservice delete --name "$bot" --resource-group "${var.resource_group_name}" --yes || {
              if [ "${var.force_cleanup}" = "true" ]; then
                echo "⚠️  Failed to delete bot service $bot, continuing due to force_cleanup=true"
              else
                exit 1
              fi
            }
          fi
        done
      else
        echo "No bot services found to delete"
      fi
      
      echo "✅ Bot Services cleanup complete"
    EOT
  }
}

# Cleanup Web Apps and App Service Plans
resource "null_resource" "cleanup_web_apps" {
  count      = local.should_cleanup ? 1 : 0
  depends_on = [null_resource.cleanup_bot_services]
  
  triggers = {
    resource_group = var.resource_group_name
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🌐 Cleaning up Web Apps and Service Plans..."
      
      # Delete web apps first
      web_apps=$(az webapp list --resource-group "${var.resource_group_name}" --query "[].name" -o tsv)
      if [ -n "$web_apps" ]; then
        echo "Deleting web apps:"
        echo "$web_apps" | while read -r app; do
          if [ -n "$app" ]; then
            echo "🗑️  Deleting web app: $app"
            az webapp delete --name "$app" --resource-group "${var.resource_group_name}" || {
              if [ "${var.force_cleanup}" = "true" ]; then
                echo "⚠️  Failed to delete web app $app, continuing..."
              else
                exit 1
              fi
            }
          fi
        done
      fi
      
      # Delete app service plans
      service_plans=$(az appservice plan list --resource-group "${var.resource_group_name}" --query "[].name" -o tsv)
      if [ -n "$service_plans" ]; then
        echo "Deleting app service plans:"
        echo "$service_plans" | while read -r plan; do
          if [ -n "$plan" ]; then
            echo "🗑️  Deleting app service plan: $plan"
            az appservice plan delete --name "$plan" --resource-group "${var.resource_group_name}" --yes || {
              if [ "${var.force_cleanup}" = "true" ]; then
                echo "⚠️  Failed to delete service plan $plan, continuing..."
              else
                exit 1
              fi
            }
          fi
        done
      fi
      
      echo "✅ Web Apps cleanup complete"
    EOT
  }
}

# Cleanup AI/ML Workspaces
resource "null_resource" "cleanup_ai_workspaces" {
  count      = local.should_cleanup ? 1 : 0
  depends_on = [null_resource.cleanup_web_apps]
  
  triggers = {
    resource_group = var.resource_group_name
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🧠 Cleaning up AI/ML Workspaces..."
      
      # Delete AI projects first, then AI hubs
      workspaces=$(az ml workspace list --resource-group "${var.resource_group_name}" --query "[].name" -o tsv 2>/dev/null || echo "")
      
      if [ -n "$workspaces" ]; then
        echo "Deleting ML workspaces:"
        echo "$workspaces" | while read -r workspace; do
          if [ -n "$workspace" ]; then
            echo "🗑️  Deleting ML workspace: $workspace"
            az ml workspace delete --name "$workspace" --resource-group "${var.resource_group_name}" --yes --no-wait || {
              if [ "${var.force_cleanup}" = "true" ]; then
                echo "⚠️  Failed to delete workspace $workspace, continuing..."
              else
                exit 1
              fi
            }
          fi
        done
        
        # Wait a bit for async deletions
        echo "⏳ Waiting for workspace deletions to complete..."
        sleep 30
      fi
      
      echo "✅ AI/ML Workspaces cleanup complete"
    EOT
  }
}

# Cleanup Cognitive Services
resource "null_resource" "cleanup_cognitive_services" {
  count      = local.should_cleanup ? 1 : 0
  depends_on = [null_resource.cleanup_ai_workspaces]
  
  triggers = {
    resource_group = var.resource_group_name
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🧠 Cleaning up Cognitive Services..."
      
      cog_services=$(az cognitiveservices account list --resource-group "${var.resource_group_name}" --query "[].name" -o tsv)
      
      if [ -n "$cog_services" ]; then
        echo "Deleting cognitive services:"
        echo "$cog_services" | while read -r service; do
          if [ -n "$service" ]; then
            echo "🗑️  Deleting cognitive service: $service"
            az cognitiveservices account delete --name "$service" --resource-group "${var.resource_group_name}" || {
              if [ "${var.force_cleanup}" = "true" ]; then
                echo "⚠️  Failed to delete service $service, continuing..."
              else
                exit 1
              fi
            }
          fi
        done
      fi
      
      echo "✅ Cognitive Services cleanup complete"
    EOT
  }
}

# Cleanup Key Vaults (with purge protection handling)
resource "null_resource" "cleanup_key_vaults" {
  count      = local.should_cleanup ? 1 : 0
  depends_on = [null_resource.cleanup_cognitive_services]
  
  triggers = {
    resource_group = var.resource_group_name
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔐 Cleaning up Key Vaults..."
      
      key_vaults=$(az keyvault list --resource-group "${var.resource_group_name}" --query "[].name" -o tsv)
      
      if [ -n "$key_vaults" ]; then
        echo "Deleting key vaults:"
        echo "$key_vaults" | while read -r vault; do
          if [ -n "$vault" ]; then
            echo "🗑️  Deleting key vault: $vault"
            
            # First try normal delete
            az keyvault delete --name "$vault" --resource-group "${var.resource_group_name}" || {
              if [ "${var.force_cleanup}" = "true" ]; then
                echo "⚠️  Failed to delete key vault $vault, continuing..."
                continue
              else
                exit 1
              fi
            }
            
            # Then purge if needed (removes it permanently)
            echo "🗑️  Purging key vault: $vault"
            az keyvault purge --name "$vault" --no-wait || {
              echo "⚠️  Could not purge key vault $vault (may not support purge or already purged)"
            }
          fi
        done
      fi
      
      echo "✅ Key Vaults cleanup complete"
    EOT
  }
}

# Cleanup Managed Identities
resource "null_resource" "cleanup_managed_identities" {
  count      = local.should_cleanup ? 1 : 0
  depends_on = [null_resource.cleanup_key_vaults]
  
  triggers = {
    resource_group = var.resource_group_name
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🆔 Cleaning up Managed Identities..."
      
      identities=$(az identity list --resource-group "${var.resource_group_name}" --query "[].name" -o tsv)
      
      if [ -n "$identities" ]; then
        echo "Deleting managed identities:"
        echo "$identities" | while read -r identity; do
          if [ -n "$identity" ]; then
            echo "🗑️  Deleting managed identity: $identity"
            az identity delete --name "$identity" --resource-group "${var.resource_group_name}" || {
              if [ "${var.force_cleanup}" = "true" ]; then
                echo "⚠️  Failed to delete identity $identity, continuing..."
              else
                exit 1
              fi
            }
          fi
        done
      fi
      
      echo "✅ Managed Identities cleanup complete"
    EOT
  }
}

# Cleanup Storage Accounts (optional based on preserve_data)
resource "null_resource" "cleanup_storage_accounts" {
  count      = local.should_cleanup && !var.preserve_data ? 1 : 0
  depends_on = [null_resource.cleanup_managed_identities]
  
  triggers = {
    resource_group = var.resource_group_name
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "💾 Cleaning up Storage Accounts..."
      
      storage_accounts=$(az storage account list --resource-group "${var.resource_group_name}" --query "[].name" -o tsv)
      
      if [ -n "$storage_accounts" ]; then
        echo "Deleting storage accounts:"
        echo "$storage_accounts" | while read -r account; do
          if [ -n "$account" ]; then
            echo "🗑️  Deleting storage account: $account"
            az storage account delete --name "$account" --resource-group "${var.resource_group_name}" --yes || {
              if [ "${var.force_cleanup}" = "true" ]; then
                echo "⚠️  Failed to delete storage account $account, continuing..."
              else
                exit 1
              fi
            }
          fi
        done
      fi
      
      echo "✅ Storage Accounts cleanup complete"
    EOT
  }
}

# Final cleanup - delete any remaining resources and optionally the resource group
resource "null_resource" "final_cleanup" {
  count = local.should_cleanup ? 1 : 0
  depends_on = [
    null_resource.cleanup_bot_services,
    null_resource.cleanup_web_apps,
    null_resource.cleanup_ai_workspaces,
    null_resource.cleanup_cognitive_services,
    null_resource.cleanup_key_vaults,
    null_resource.cleanup_managed_identities,
    null_resource.cleanup_storage_accounts
  ]
  
  triggers = {
    resource_group = var.resource_group_name
    preserve_data  = var.preserve_data
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🧹 Final cleanup sweep..."
      
      # Check for any remaining resources
      remaining=$(az resource list --resource-group "${var.resource_group_name}" --query "length(@)")
      
      if [ "$remaining" -gt 0 ]; then
        echo "📋 Remaining resources in resource group:"
        az resource list --resource-group "${var.resource_group_name}" --query "[].{Name:name, Type:type}" --output table
        
        if [ "${var.preserve_data}" = "true" ]; then
          echo "ℹ️  Some resources preserved due to preserve_data=true"
        elif [ "${var.force_cleanup}" = "true" ]; then
          echo "🗑️  Force deleting remaining resources..."
          az resource delete --ids $(az resource list --resource-group "${var.resource_group_name}" --query "[].id" -o tsv) || {
            echo "⚠️  Some resources could not be force deleted"
          }
        else
          echo "⚠️  Some resources remain. Consider setting force_cleanup=true if needed."
        fi
      else
        echo "✅ No remaining resources found"
      fi
      
      # Optionally delete the resource group if empty or force_cleanup is true
      remaining_after=$(az resource list --resource-group "${var.resource_group_name}" --query "length(@)")
      
      if [ "$remaining_after" -eq 0 ] || [ "${var.force_cleanup}" = "true" ]; then
        echo "🗑️  Deleting resource group: ${var.resource_group_name}"
        az group delete --name "${var.resource_group_name}" --yes --no-wait || {
          echo "⚠️  Failed to delete resource group, may require manual cleanup"
        }
      else
        echo "ℹ️  Resource group kept due to remaining resources"
      fi
      
      echo "✅ Cleanup complete!"
    EOT
  }
}

# Cleanup Terraform files and state
resource "null_resource" "cleanup_terraform_files" {
  count = local.should_cleanup ? 1 : 0
  depends_on = [null_resource.final_cleanup]
  
  triggers = {
    resource_group = var.resource_group_name
    force_cleanup  = var.force_cleanup
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🗂️  Cleaning up Terraform files..."
      
      # Navigate to the main infra directories
      MAIN_INFRA_DIR="$(dirname "$(pwd)")"
      INFRA_TF_DIR="$MAIN_INFRA_DIR"
      INFRA_BICEP_DIR="$(dirname "$MAIN_INFRA_DIR")/infra"
      
      echo "📁 Checking directories:"
      echo "  - Main infra_tf: $INFRA_TF_DIR"
      echo "  - Bicep infra: $INFRA_BICEP_DIR"
      
      # Clean up Terraform state files in infra_tf
      if [ -d "$INFRA_TF_DIR" ]; then
        echo "🗑️  Cleaning Terraform state files in $INFRA_TF_DIR"
        cd "$INFRA_TF_DIR"
        
        # Remove state files
        [ -f "terraform.tfstate" ] && rm -f terraform.tfstate && echo "  ✓ Removed terraform.tfstate"
        [ -f "terraform.tfstate.backup" ] && rm -f terraform.tfstate.backup && echo "  ✓ Removed terraform.tfstate.backup"
        
        # Remove .terraform directory
        [ -d ".terraform" ] && rm -rf .terraform && echo "  ✓ Removed .terraform directory"
        
        # Remove lock file
        [ -f ".terraform.lock.hcl" ] && rm -f .terraform.lock.hcl && echo "  ✓ Removed .terraform.lock.hcl"
        
        # Remove any crash logs
        find . -name "crash.log" -delete 2>/dev/null && echo "  ✓ Removed crash logs"
        
        # Remove any .tfplan files
        find . -name "*.tfplan" -delete 2>/dev/null && echo "  ✓ Removed plan files"
      fi
      
      # Clean up Azure deployment cache and temp files
      echo "🗑️  Cleaning Azure deployment cache..."
      
      # Remove .azure directory if it exists (azd environment)
      AZURE_DIR="$(dirname "$MAIN_INFRA_DIR")/.azure"
      if [ -d "$AZURE_DIR" ]; then
        rm -rf "$AZURE_DIR" && echo "  ✓ Removed .azure directory"
      fi
      
      # Clean up any bicep compiled ARM templates
      if [ -d "$INFRA_BICEP_DIR" ]; then
        echo "🗑️  Cleaning compiled ARM templates in $INFRA_BICEP_DIR"
        find "$INFRA_BICEP_DIR" -name "*.json" -not -name "main.parameters.json" -not -name "abbreviations.json" -delete 2>/dev/null && echo "  ✓ Removed compiled ARM templates"
      fi
      
      # Clean up any deployment logs
      echo "🗑️  Cleaning deployment logs..."
      find "$(dirname "$MAIN_INFRA_DIR")" -name "deployment-*.log" -delete 2>/dev/null && echo "  ✓ Removed deployment logs"
      find "$(dirname "$MAIN_INFRA_DIR")" -name "azd-*.log" -delete 2>/dev/null && echo "  ✓ Removed azd logs"
      
      # Clean up VS Code settings that might contain deployment-specific info
      VSCODE_DIR="$(dirname "$MAIN_INFRA_DIR")/.vscode"
      if [ -d "$VSCODE_DIR" ]; then
        echo "🗑️  Cleaning VS Code deployment settings..."
        [ -f "$VSCODE_DIR/settings.json.bak" ] && rm -f "$VSCODE_DIR/settings.json.bak" && echo "  ✓ Removed VS Code settings backup"
      fi
      
      # Clean up any environment-specific files
      echo "🗑️  Cleaning environment files..."
      PROJECT_ROOT="$(dirname "$MAIN_INFRA_DIR")"
      [ -f "$PROJECT_ROOT/.env.local" ] && rm -f "$PROJECT_ROOT/.env.local" && echo "  ✓ Removed .env.local"
      [ -f "$PROJECT_ROOT/.env.production" ] && rm -f "$PROJECT_ROOT/.env.production" && echo "  ✓ Removed .env.production"
      
      # Clean up any temporary build artifacts
      echo "🗑️  Cleaning build artifacts..."
      find "$PROJECT_ROOT" -name "node_modules" -type d -prune -o -name "*.tmp" -delete 2>/dev/null && echo "  ✓ Removed temporary files"
      find "$PROJECT_ROOT" -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null && echo "  ✓ Removed pytest cache"
      find "$PROJECT_ROOT" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null && echo "  ✓ Removed Python cache"
      
      echo "✅ Terraform and deployment files cleanup complete!"
      echo ""
      echo "📋 Summary of cleaned files:"
      echo "  • Terraform state files (.tfstate, .tfstate.backup)"
      echo "  • Terraform provider cache (.terraform/)"
      echo "  • Terraform lock files (.terraform.lock.hcl)"
      echo "  • Azure CLI deployment cache (.azure/)"
      echo "  • Compiled ARM templates (*.json, except parameters)"
      echo "  • Deployment and azd logs"
      echo "  • Temporary environment files"
      echo "  • Build artifacts and cache directories"
      echo ""
      echo "🎯 Your workspace is now clean and ready for a fresh deployment!"
    EOT
  }
}

# Output cleanup summary
output "cleanup_summary" {
  description = "Summary of cleanup operations"
  value = local.should_cleanup ? {
    resource_group       = var.resource_group_name
    preserve_data        = var.preserve_data
    force_cleanup        = var.force_cleanup
    cleanup_performed    = true
    terraform_files_cleaned = true
    message             = "Complete cleanup operations initiated including Terraform files. Check logs for detailed results."
  } : {
    cleanup_performed      = false
    terraform_files_cleaned = false
    message               = "Cleanup not performed. Set confirm_destroy='yes' to proceed."
  }
}
