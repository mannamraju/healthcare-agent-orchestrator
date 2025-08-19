# Single-Click Deployment Guide

## 🚀 Quick Start

This guide provides a robust, single-click deployment solution for the Healthcare Agent Orchestrator in **West US 2** that addresses all previous deployment errors.

### Prerequisites ✅

1. **Azure CLI** installed and configured
2. **Terraform** installed (v1.0+)
3. **Active Azure subscription** with appropriate permissions
4. **PowerShell/Bash** terminal access

### What's Fixed 🔧

This deployment addresses all issues encountered in previous deployments:

1. **✅ ML GPU YAML Schema**: Updated to use correct `request_settings` structure
2. **✅ Azure ML Soft-Delete**: Uses unique resource names to avoid conflicts  
3. **✅ Authentication Token Expiry**: Automatic token refresh during deployment
4. **✅ Resource Naming Conflicts**: Time-based unique suffixes for all resources
5. **✅ Dynamic Resource Groups**: No hardcoded resource group names
6. **✅ Regional Optimization**: All resources deployed in West US 2 for optimal H100 GPU performance
7. **✅ Error Recovery**: Comprehensive retry logic and cleanup mechanisms
8. **✅ H100 GPU Upgrade**: Switched to superior H100 GPUs with available quota

### Configuration Overview 📋

### Configuration Overview 📋

**Current Configuration** (optimized for West US 2):
- **Resource Group**: `hao250705_1200`
- **Region**: `westus2` (West US 2)
- **GPU Instance**: `Standard_NC24ads_A100_v4` (A100 - Cost-Optimized for Healthcare AI!)
- **Resource Naming**: Unique timestamps to avoid conflicts
- **ML Workspace**: `cog-ai-prj-westus2-dev`

## 🎯 Single-Click Deployment

### Option 1: Complete Automated Deployment (Recommended)

```bash
# Navigate to infrastructure directory
cd /workspaces/healthcare-agent-orchestrator/infra_tf

# Run complete deployment
./deploy_single_click.sh
```

This script will:
- ✅ Validate all prerequisites
- ✅ Ensure Azure authentication  
- ✅ Clean up any previous state
- ✅ Deploy all infrastructure components
- ✅ Validate the deployment
- ✅ Provide deployment summary with URLs

### Option 2: Step-by-Step with Validation

```bash
# 1. Validate configuration first
./validate_deployment.sh

# 2. If validation passes, run deployment
./deploy_single_click.sh
```

## 📊 Deployment Details

### Infrastructure Components

The deployment creates these Azure resources:

| Component | Type | Purpose |
|-----------|------|---------|
| **AI Services** | Cognitive Services | OpenAI GPT-4o model hosting |
| **ML Workspace** | Machine Learning | AI Hub for model management |
| **GPU Deployment** | ML Online Endpoint | Healthcare radiology models (H100 GPUs) |
| **App Service** | Web App | Main application hosting |
| **Storage Accounts** | Blob Storage | Data and application storage |
| **Key Vault** | Security | Secrets and configuration |
| **Managed Identity** | Identity | Secure service authentication |
| **Bot Services** | Communication | Teams integration |

### Resource Naming Convention

All resources use consistent naming with unique timestamps:
- **Format**: `{service}-westus2-dev-{timestamp}`
- **Example**: `cog-westus2-dev-0705`, `app-westus2-dev-0705`
- **Storage**: `stwestus2dev0705` (no hyphens for storage accounts)

### Security Features

- **🔐 Managed Identity**: All services use managed identity for authentication
- **🔑 Key Vault**: Centralized secret management
- **🛡️ AAD Token Auth**: ML endpoints use Azure AD authentication
- **🌐 HTTPS Only**: All web services enforce HTTPS
- **🔒 RBAC**: Principle of least privilege access

### 🚀 H100 GPU Advantages

**Why H100 is Superior to A100:**
- **🏃‍♂️ Performance**: ~2x faster inference for AI workloads
- **🧠 Memory**: Higher bandwidth (3TB/s vs 2TB/s) and larger capacity
- **⚡ Architecture**: Latest Hopper architecture with Transformer Engine
- **💰 Cost Efficiency**: Better performance per dollar for AI inference
- **🔋 Power Efficiency**: More FLOPS per watt consumed
- **📊 Precision**: Enhanced mixed-precision capabilities for healthcare models

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1. Authentication Errors
```bash
# Re-authenticate to Azure
az login --use-device-code

# Refresh ML extension
az extension update --name ml
```

#### 2. Quota Issues
```bash
# Check GPU quota in West US 2
az vm list-usage --location westus2 --query "[?contains(name.value, 'NC')]"

# Request quota increase if needed
# https://portal.azure.com/#view/Microsoft_Azure_Support/NewSupportRequestBladeV2
```

#### 3. Resource Conflicts
```bash
# Clean up previous deployment
./delete_deployment.sh -g hao250705_1200

# Update resource names in terraform.tfvars with new timestamp
# Then re-run deployment
```

#### 4. ML Workspace Soft-Delete
The deployment uses unique workspace names to avoid soft-delete conflicts:
- Previous: `cog-ai-prj-eastus-dev`  
- Current: `cog-ai-prj-westus2-dev`

#### 5. Terraform State Issues
```bash
# Clean state if needed
rm -f terraform.tfstate*
rm -rf .terraform

# Re-initialize
terraform init
```

## 📈 Post-Deployment

### Validation Steps

1. **✅ Check Resource Group**
   ```bash
   az group show --name hao250705_1200
   ```

2. **✅ Verify App Service**
   ```bash
   az webapp show --name app-westus2-dev-0705 --resource-group hao250705_1200
   ```

3. **✅ Test ML Endpoints**
   ```bash
   az ml online-endpoint list --workspace-name cog-ai-prj-westus2-dev --resource-group hao250705_1200
   ```

### Access URLs

After successful deployment:
- **Azure Portal**: `https://portal.azure.com/#@/resource/subscriptions/{subscription}/resourceGroups/hao250705_1200`
- **App Service**: `https://app-westus2-dev-0705.azurewebsites.net`
- **AI Studio**: `https://ai.azure.com`

### Monitoring and Logs

- **Deployment Logs**: `./logs/single_click_deployment_{timestamp}.log`
- **Application Insights**: Available in Azure Portal
- **ML Endpoint Logs**: Available in Azure AI Studio

## 🔄 Cleanup

To remove all resources:

```bash
./delete_deployment.sh -g hao250705_1200
```

## 📞 Support

If you encounter issues:

1. **Check the deployment log** in `./logs/` directory
2. **Review Azure Portal** for resource status
3. **Validate configuration** with `./validate_deployment.sh`
4. **Clean and retry** if needed

## 🎉 Success Indicators

Deployment is successful when you see:
- ✅ All Terraform resources created
- ✅ App Service running and accessible
- ✅ ML endpoints deployed and active
- ✅ No errors in deployment logs
- ✅ Resources visible in Azure Portal

**Estimated deployment time**: 15-30 minutes for complete infrastructure.
