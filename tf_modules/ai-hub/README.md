# Healthcare Agent Orchestrator - AI Hub Deployment

This directory contains Terraform configuration for deploying the AI Hub components of the Healthcare Agent Orchestrator (HAO) in Azure.

## What This Deploys

- Azure AI Hub (Cognitive Services Account with kind="AIHub")
- AI Project in the AI Hub
- Links to existing OpenAI service
- Role assignments for secure access

## Prerequisites

Before deploying this module, you must have:

1. Deployed the core infrastructure (Resource Group, Key Vault)
2. Deployed the AI Services (OpenAI)

## Deployment Steps

To deploy the AI Hub:

1. Navigate to the AI Hub directory
2. Initialize Terraform
   ```
   terraform init
   ```
3. Create a plan
   ```
   terraform plan -out=ai-hub.plan
   ```
4. Apply the plan
   ```
   terraform apply "ai-hub.plan"
   ```

## Resources

The deployment creates an Azure AI Hub and a project which orchestrates:

- Language understanding capabilities
- Healthcare-specific AI capabilities
- Model execution environments
- Integration with OpenAI services

## Configuration

The configuration uses variables defined in `variables.tf` with reasonable defaults:

- AI Hub Name: `aihub-hao-0816`
- AI Project Name: `ai-project-hao-0816`
- Links to existing OpenAI service and Key Vault

## Next Steps

After deploying the AI Hub, you can:

1. Deploy Healthcare Agent Service
2. Deploy the App Service components
3. Set up Bot Service for chat integration
