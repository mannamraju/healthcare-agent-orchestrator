# Healthcare Agent Orchestrator - AI Services Deployment

This directory contains Terraform configuration for deploying the AI Services components of the Healthcare Agent Orchestrator (HAO) in Azure.

## AI Services Components

The following resources will be deployed:

- Azure OpenAI Service
- GPT-4 Model Deployment
- Key Vault Secrets for OpenAI endpoints and keys
- Role assignments for secure access

## Prerequisites

- Core infrastructure components must be deployed first (Resource Group, Key Vault)
- Azure subscription with Azure OpenAI Service enabled
- Sufficient quota for GPT-4 deployment

## Deployment Instructions

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Validate configuration:
   ```bash
   terraform validate
   ```

3. Plan deployment:
   ```bash
   terraform plan -out ai-services.plan
   ```

4. Apply deployment:
   ```bash
   terraform apply "ai-services.plan"
   ```

## Configuration

This deployment uses the following configuration:

- OpenAI Service Name: `oai-hao-0816`
- Region: `westus`
- Model: `gpt-4` version `0125-preview`
- Capacity: 80 tokens-per-minute (TPM)

## Important Notes

- Azure OpenAI Services require specific quota allocations in your subscription
- GPT-4 model deployment may take 10-15 minutes to complete
- The role assignment may take some time to propagate (30s delay added)

## Clean Up

To remove all created resources:

```bash
terraform destroy
```
