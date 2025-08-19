# Healthcare Agent Orchestrator Terraform Deployment Guide

## Overview

This document provides instructions for deploying the Healthcare Agent Orchestrator (HAO) infrastructure using a pure Terraform approach without PowerShell scripts. The deployment uses modular Terraform configurations to create all required Azure resources.

## Prerequisites

- Terraform v1.0.0 or later
- Azure CLI installed and authenticated
- Contributor access to an Azure subscription
- Azure AD permissions to create role assignments (if needed)

## Core Infrastructure

The core infrastructure includes:

- Resource Group
- Storage Accounts
- Virtual Network and Subnet
- Network Security Group
- Key Vault

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

This will download the required providers and initialize the Terraform backend.

### 2. Validate Configuration

```bash
terraform validate
```

This command will check if your configuration is valid.

### 3. Plan Deployment

```bash
terraform plan -out=deploy.plan
```

Review the plan carefully to ensure all resources will be created as expected.

### 4. Apply Deployment

```bash
terraform apply "deploy.plan"
```

This will create all the resources defined in your Terraform configuration.

## Core Infrastructure Module

The core infrastructure is defined in the `modules/core-infrastructure` module, which creates:

- Resource Group: `hao_0816`
- Storage Account: `haowest0816sa`
- App Storage Account: `appwest0816sa`
- Virtual Network: `vnet-hao-0816-west`
- Subnet: `default`
- Network Security Group with HTTPS rule
- Key Vault: `kv-westus-hao0816`

## Advanced Configuration

### Storage Account Configuration

Storage accounts are configured with:
- Standard performance tier
- Locally redundant storage (LRS)
- StorageV2 account kind
- TLS 1.2 minimum version
- Public access blocked for nested items

### Key Vault Configuration

The Key Vault is configured with:
- Standard SKU
- Soft delete retention of 7 days
- Access policy for the deployment user

## Monitoring Deployment

Monitor the deployment in the Azure portal or using Azure CLI:

```bash
az group deployment list --resource-group hao_0816
```

## Next Steps

After deploying the core infrastructure:

1. Deploy application services
2. Configure AI services
3. Set up healthcare agent components
4. Configure networking and access control

## Clean Up Resources

To remove all created resources:

```bash
terraform destroy
```

This will delete all resources created by Terraform.
