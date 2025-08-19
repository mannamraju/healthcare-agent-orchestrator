# Healthcare Agent Simplified Deployment

This project provides a streamlined approach to deploy the Healthcare Agent on Azure. We've simplified the deployment process using Terraform and created user-friendly scripts.

## What's Included

1. **Terraform Configuration**
   - Simplified main.tf with core resources
   - Streamlined variables.tf with essential parameters
   - Provider configuration handling

2. **Deployment Scripts**
   - PowerShell deployment script with extensive error checking
   - Bash deployment script for Linux/macOS users
   - TestRun mode for validation without resource creation

3. **Validation & Troubleshooting**
   - Validation script to verify deployed resources
   - Troubleshooting script to diagnose common issues
   - Detailed logs and error messages

4. **Documentation**
   - Quick start guide for rapid deployment
   - Comprehensive deployment guide with troubleshooting
   - Architecture overview and resource explanation

## Key Improvements

- **Simplified Architecture**: Focused on essential resources for Healthcare Agent
- **Error Handling**: Robust error detection and informative messages
- **User Guidance**: Clear instructions with placeholder examples
- **Cross-Platform**: Support for Windows, Linux and macOS
- **Validation**: Built-in checks to verify deployment success

## Deployment Files

```
simplified_deployment/
├── main.tf           # Core Terraform configuration
├── variables.tf      # Variable definitions
├── README.md         # Detailed deployment instructions
└── provider_override.tf  # Provider version management

Scripts:
├── deploy_simplified.ps1        # PowerShell deployment script
├── deploy_simplified.sh         # Bash deployment script
├── validate_simplified.ps1      # PowerShell validation script
├── cleanup_simplified.ps1       # PowerShell cleanup script
├── cleanup_simplified.sh        # Bash cleanup script
└── troubleshoot_deployment.ps1  # Deployment troubleshooting script

Documentation:
├── QUICKSTART.md                # Simple step-by-step guide
├── DEPLOYMENT_GUIDE.md          # Comprehensive deployment instructions
└── SIMPLIFIED_DEPLOYMENT.md     # Overview of the simplified deployment
```

## Usage

For quick deployment:

```powershell
.\deploy_simplified.ps1 -SubscriptionId "<your-actual-subscription-id>" -ResourceGroupName "<your-resource-group>" -EnvironmentName "dev"
```

For validation:

```powershell
.\validate_simplified.ps1 -SubscriptionId "<your-actual-subscription-id>" -ResourceGroupName "<your-resource-group>"
```

For troubleshooting:

```powershell
.\troubleshoot_deployment.ps1 -SubscriptionId "<your-actual-subscription-id>" -ResourceGroupName "<your-resource-group>"
```
