# Healthcare Agent Orchestrator - Script Reference Guide

This guide explains the purpose and usage of each script in the HAO-TF repository.

## Core Deployment Scripts

| Script Name | Purpose | When to Use |
|-------------|---------|-------------|
| `deploy_comprehensive.ps1` | Deploys the complete Healthcare Agent environment | Standard deployment of all components |
| `deploy_hao_0816_west_terraform.ps1` | West region-specific deployment from Aug 16 | When specifically targeting West region |
| `fresh_start.ps1` | Cleans up resources and prepares for a fresh deployment | When previous deployments failed and you need to start over |
| `deploy_end_to_end.ps1` | Complete process: deploy, validate, and health check | For full lifecycle deployment with validation |

## Utility Scripts

| Script Name | Purpose | When to Use |
|-------------|---------|-------------|
| `monitor_comprehensive.ps1` | Real-time monitoring of deployment progress | During deployment to watch resource creation |
| `health_check_comprehensive.ps1` | Checks the health of deployed resources | After deployment to verify everything is working |
| `validate_comprehensive.ps1` | Validates that all resources were created | After deployment to ensure completeness |
| `initialize_providers.ps1` | Registers required Azure resource providers | Before first deployment in a subscription |

## Bash Alternatives

| PowerShell Script | Bash Equivalent | Platform |
|-------------------|----------------|----------|
| `deploy_comprehensive.ps1` | `deploy_comprehensive.sh` | Linux/macOS |
| `fresh_start.ps1` | `fresh_start.sh` | Linux/macOS |

## Workflow Examples

### Standard Deployment Flow:

```powershell
# 1. Initialize providers (first time only)
.\initialize_providers.ps1 -SubscriptionId "your-subscription-id"

# 2. Deploy comprehensive environment
.\deploy_comprehensive.ps1 -SubscriptionId "your-subscription-id" -ResourceGroup "your-resource-group" -EnvironmentName "dev"

# 3. Validate deployment
.\validate_comprehensive.ps1 -SubscriptionId "your-subscription-id" -ResourceGroup "your-resource-group"

# 4. Check health
.\health_check_comprehensive.ps1 -SubscriptionId "your-subscription-id" -ResourceGroup "your-resource-group"
```

### Quick End-to-End Deployment:

```powershell
# Single command to handle deployment, validation, and health check
.\deploy_end_to_end.ps1 -SubscriptionId "your-subscription-id" -ResourceGroup "your-resource-group" -EnvironmentName "dev"
```

### Recovery Flow:

```powershell
# 1. Start fresh to clear any partial deployments
.\fresh_start.ps1 -SubscriptionId "your-subscription-id" -ResourceGroup "your-resource-group"

# 2. Try deployment again
.\deploy_comprehensive.ps1 -SubscriptionId "your-subscription-id" -ResourceGroup "your-resource-group" -EnvironmentName "dev"
```

## Maintenance Tasks

| Task | Script to Use | Command |
|------|--------------|---------|
| Check current deployment status | `monitor_comprehensive.ps1` | `.\monitor_comprehensive.ps1 -SubscriptionId "id" -ResourceGroup "rg"` |
| Validate existing deployment | `validate_comprehensive.ps1` | `.\validate_comprehensive.ps1 -SubscriptionId "id" -ResourceGroup "rg"` |
| Check resource health | `health_check_comprehensive.ps1` | `.\health_check_comprehensive.ps1 -SubscriptionId "id" -ResourceGroup "rg"` |
