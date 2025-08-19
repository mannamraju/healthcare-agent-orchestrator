# Healthcare Agent Orchestrator - Core Infrastructure Deployment

This directory contains Terraform configuration for deploying the core infrastructure resources for the Healthcare Agent Orchestrator (HAO) in Azure.

## Core Infrastructure Resources

The following resources will be deployed:

- Resource Group
- Storage Account (for general use)
- App Storage Account (for application-specific storage)
- Virtual Network with Subnet
- Network Security Group with HTTPS rule
- Key Vault

## Deployment Instructions

To deploy only the core infrastructure components:

1. Navigate to the core-infra directory:
   ```bash
   cd core-infra
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Validate configuration:
   ```bash
   terraform validate
   ```

4. Plan deployment:
   ```bash
   terraform plan -out=core.plan
   ```

5. Apply deployment:
   ```bash
   terraform apply "core.plan"
   ```

## Configuration

This deployment uses the following configuration:

- Resource Group: `hao_0816`
- Region: `westus`
- Storage Account: `haowest0816sa`
- App Storage Account: `appwest0816sa`
- Virtual Network: `vnet-hao-0816-west` (10.0.0.0/16)
- Subnet: `default` (10.0.0.0/24)
- Key Vault: `kv-westus-hao0816`

## Resource Requirements

- Sufficient permissions to create resources in your Azure subscription
- Azure provider version ~> 4.0.0
- Terraform version >= 1.0.0

## Post-Deployment

After deploying the core infrastructure, you can use the outputs to configure other services or continue with the deployment of the complete HAO solution.

## Clean Up

To remove all created resources:

```bash
terraform destroy
```

Note: This will remove ALL resources created by this configuration. Use with caution in shared environments.
